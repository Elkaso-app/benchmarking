"""Invoice processing using OpenAI GPT-4 Vision API."""
import base64
import time
import json
from pathlib import Path
from typing import List, Tuple, Optional
import statistics
import fitz  # PyMuPDF

from openai import OpenAI

from config import settings
from models import InvoiceData, ProcessingResult, InvoiceItem


class InvoiceProcessor:
    """Processes invoices using OpenAI GPT-4 Vision API."""
    
    def __init__(self):
        """Initialize the processor with OpenAI client."""
        self.client = OpenAI(api_key=settings.openai_api_key)
        self.model = settings.openai_model
    
    def pdf_to_images(self, pdf_path: Path, max_pages: int = 5) -> List[bytes]:
        """Convert PDF pages to images.
        
        Args:
            pdf_path: Path to PDF file
            max_pages: Maximum number of pages to process
            
        Returns:
            List of image bytes
        """
        images = []
        doc = fitz.open(pdf_path)
        
        for page_num in range(min(len(doc), max_pages)):
            page = doc[page_num]
            # Render page to image at 300 DPI for better quality
            pix = page.get_pixmap(matrix=fitz.Matrix(300/72, 300/72))
            img_bytes = pix.tobytes("png")
            images.append(img_bytes)
        
        doc.close()
        return images
    
    def encode_image_base64(self, image_bytes: bytes) -> str:
        """Encode image bytes to base64 string.
        
        Args:
            image_bytes: Raw image bytes
            
        Returns:
            Base64 encoded string
        """
        return base64.b64encode(image_bytes).decode('utf-8')
    
    def create_extraction_prompt(self, strict: bool = False) -> str:
        """Create the prompt for invoice data extraction."""
        base = """You are an expert invoice data extractor. Analyze this invoice image and extract ALL items in a structured format.

Extract the following information:
1. Invoice metadata (number, date, vendor, customer, currency)
2. ALL line items with:
   - Item number/sequence
   - Description (exact text from invoice)
   - Quantity
   - Unit price
   - Total price (net amount/amount before tax)
   - Unit of measurement (if present)
   - LLM confidence score from 0 to 10 (higher = more confident). Use decimals if needed.
3. Financial totals (subtotal, tax, total amount)

Return ONLY a valid JSON object with this exact structure:
{
  "invoice_number": "string or null",
  "invoice_date": "string or null",
  "vendor_name": "string or null",
  "customer_name": "string or null",
  "currency": "string or null",
  "items": [
    {
      "item_number": number or null,
      "description": "string",
      "quantity": number or null,
      "unit_price": number or null,
      "total": number or null,
      "unit": "string or null",
      "llm_confidence": number (0 to 10)
    }
  ],
  "subtotal": number or null,
  "tax": number or null,
  "total_amount": number or null
}

CRITICAL VALIDATION RULES:
- For each item, VERIFY that: quantity × unit_price = total (net amount)
- The "total" field should be the NET AMOUNT or AMOUNT BEFORE TAX (NOT the gross total with VAT)
- If the math doesn't match, re-read the invoice carefully and correct the values
- Extract values from the correct columns: Quantity, Price (unit price), Amount Before Tax (total)
- If you cannot read an item with at least 85% confidence/accuracy, SKIP that item entirely (llm_confidence < 8.5 → SKIP)
- Only include items where you are confident about all values (description, quantity, unit_price, total)

Important:
- Extract ONLY items you can read clearly and accurately (≥85% confidence)
- Keep descriptions exactly as they appear
- Use null for missing values
- Ensure all numbers are numeric types (not strings)
- ALWAYS validate: quantity × unit_price = total
- Return ONLY valid JSON, no additional text"""

        if not strict:
            return base

        # Stricter prompt for retry: reduces column swap/decimal issues.
        strict_addon = """

STRICT MODE (RETRY):
- The invoice contains a line-items TABLE with headers (examples): Unit | Qty | Rate | Total | VAT% | VAT Amount | Amount
- Extract ONLY from the correct columns by header:
  - quantity = value under 'Qty'
  - unit_price = value under 'Rate'
  - total = value under 'Total' (net amount before VAT)
- DO NOT swap Qty and Rate. If unsure, SKIP the item (llm_confidence < 8.5).
- Preserve decimals exactly as printed (e.g., 1.100, 4.500, 4.950).
- Double-check each line by re-reading the same row across the columns before returning it.
"""
        return base + strict_addon
    
    def process_with_openai(self, image_bytes: bytes, mime_type: str, strict: bool = False) -> InvoiceData:
        """Process invoice using OpenAI GPT-4 Vision.
        
        Args:
            image_bytes: Image bytes of the invoice
            mime_type: MIME type for the image (image/png, image/jpeg, ...)
            strict: Whether to use strict extraction prompt (retry mode)
            
        Returns:
            Extracted invoice data
        """
        base64_image = self.encode_image_base64(image_bytes)
        
        response = self.client.chat.completions.create(
            model=self.model,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": self.create_extraction_prompt(strict=strict)
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:{mime_type};base64,{base64_image}"
                            }
                        }
                    ]
                }
            ],
            max_tokens=4096,
            temperature=0
        )
        
        result_text = response.choices[0].message.content
        
        # Extract JSON from response
        json_str = result_text.strip()
        if json_str.startswith("```json"):
            json_str = json_str[7:]
        if json_str.startswith("```"):
            json_str = json_str[3:]
        if json_str.endswith("```"):
            json_str = json_str[:-3]
        json_str = json_str.strip()
        
        # Parse and validate
        data = json.loads(json_str)
        return InvoiceData(**data)

    def _normalize_and_filter_items(self, invoice_data: InvoiceData) -> InvoiceData:
        """
        Post-process items:
        - Drop low-confidence items (llm_confidence < 8.5)
        - Attempt to fix obvious qty/rate swap using a median heuristic
        - Attempt to fix decimal scale errors when math doesn't match
        """
        items = list(invoice_data.items or [])
        if not items:
            return invoice_data

        # Drop low-confidence items
        filtered: List[InvoiceItem] = []
        for it in items:
            conf = getattr(it, "llm_confidence", None)
            if conf is not None and conf < 8.5:
                continue
            filtered.append(it)

        if not filtered:
            invoice_data.items = []
            return invoice_data

        # Median unit_price to help choose swap direction
        prices = [i.unit_price for i in filtered if i.unit_price is not None]
        median_price: Optional[float] = None
        if prices:
            try:
                median_price = float(statistics.median(prices))
            except Exception:
                median_price = None

        def within(x: float, lo: float, hi: float) -> bool:
            return lo <= x <= hi

        def score_price(p: float) -> float:
            if median_price is None:
                return 0.0
            return abs(p - median_price)

        # Fixups
        fixed: List[InvoiceItem] = []
        for it in filtered:
            q = it.quantity
            p = it.unit_price
            t = it.total

            # Only operate when we have numbers
            if q is not None and p is not None and t is not None:
                # 1) If math matches, consider swap if it seems more plausible
                if abs((q * p) - t) <= 0.01:
                    # Swap heuristic: does swapping make price closer to median?
                    # (helps for zucchini-like cases where both satisfy multiplication)
                    if (
                        median_price is not None
                        and within(float(q), 0.001, 5000.0)
                        and within(float(p), 0.001, 5000.0)
                    ):
                        current = score_price(float(p))
                        swapped = score_price(float(q))
                        # If swapping makes unit_price much closer to median, accept swap
                        if swapped + 1e-9 < current * 0.5:
                            it.quantity, it.unit_price = it.unit_price, it.quantity
                            # small confidence penalty for auto-fix
                            if it.llm_confidence is not None:
                                it.llm_confidence = max(0.0, float(it.llm_confidence) - 0.5)
                else:
                    # 2) Decimal scale fix: try scaling qty or price by 10/100
                    candidates: List[Tuple[float, float]] = []
                    scales = [0.1, 0.01, 10.0, 100.0]
                    for s in scales:
                        candidates.append((float(q) * s, float(p)))  # scale qty
                        candidates.append((float(q), float(p) * s))  # scale price
                    best = None
                    for q2, p2 in candidates:
                        if abs((q2 * p2) - float(t)) <= 0.01 and within(q2, 0.0001, 100000.0) and within(p2, 0.0001, 100000.0):
                            # choose the candidate with unit_price closer to median
                            metric = score_price(p2) if median_price is not None else 0.0
                            if best is None or metric < best[0]:
                                best = (metric, q2, p2)
                    if best is not None:
                        _, q2, p2 = best
                        it.quantity = float(q2)
                        it.unit_price = float(p2)
                        if it.llm_confidence is not None:
                            it.llm_confidence = max(0.0, float(it.llm_confidence) - 0.7)

            fixed.append(it)

        invoice_data.items = fixed
        return invoice_data

    def _invalid_ratio(self, invoice_data: InvoiceData) -> float:
        items = invoice_data.items or []
        if not items:
            return 1.0
        invalid = 0
        checked = 0
        for it in items:
            if it.quantity is None or it.unit_price is None or it.total is None:
                invalid += 1
                checked += 1
                continue
            checked += 1
            if abs((it.quantity * it.unit_price) - it.total) > 0.01:
                invalid += 1
        return invalid / max(1, checked)

    def _mime_for_suffix(self, suffix: str) -> str:
        s = suffix.lower()
        if s in [".jpg", ".jpeg"]:
            return "image/jpeg"
        if s == ".png":
            return "image/png"
        if s == ".gif":
            return "image/gif"
        if s == ".webp":
            return "image/webp"
        # fallback
        return "image/png"
    
    def process_invoice(self, file_path: Path) -> ProcessingResult:
        """Process a single invoice file (PDF or image).
        
        Args:
            file_path: Path to the invoice file (PDF, JPG, JPEG, PNG)
            
        Returns:
            Processing result with extracted data
        """
        start_time = time.time()
        filename = file_path.name
        
        try:
            # Check if file is an image or PDF
            file_ext = file_path.suffix.lower()
            
            if file_ext in ['.jpg', '.jpeg', '.png', '.gif', '.webp']:
                # Read image file directly
                with open(file_path, 'rb') as f:
                    image_bytes = f.read()
                images = [(image_bytes, self._mime_for_suffix(file_ext))]
            elif file_ext == '.pdf':
                # Convert PDF to images
                images = [(b, "image/png") for b in self.pdf_to_images(file_path, max_pages=1)]  # first page
            else:
                return ProcessingResult(
                    filename=filename,
                    success=False,
                    error=f"Unsupported file type: {file_ext}",
                    processing_time=time.time() - start_time,
                    model_used=self.model
                )
            
            if not images:
                return ProcessingResult(
                    filename=filename,
                    success=False,
                    error="No images extracted from file",
                    processing_time=time.time() - start_time,
                    model_used=self.model
                )
            
            # Process with OpenAI (with validation + single retry)
            image_bytes, mime_type = images[0]
            invoice_data = self.process_with_openai(image_bytes, mime_type, strict=False)
            invoice_data = self._normalize_and_filter_items(invoice_data)

            # If too many invalid lines, retry once with strict prompt
            if self._invalid_ratio(invoice_data) > 0.25:
                invoice_data_retry = self.process_with_openai(image_bytes, mime_type, strict=True)
                invoice_data_retry = self._normalize_and_filter_items(invoice_data_retry)
                # Choose the better result (lower invalid ratio; tie-breaker: more items)
                r1 = self._invalid_ratio(invoice_data)
                r2 = self._invalid_ratio(invoice_data_retry)
                if (r2 < r1) or (r2 == r1 and len(invoice_data_retry.items) > len(invoice_data.items)):
                    invoice_data = invoice_data_retry
            
            processing_time = time.time() - start_time
            
            return ProcessingResult(
                filename=filename,
                success=True,
                invoice_data=invoice_data,
                processing_time=processing_time,
                model_used=self.model
            )
            
        except Exception as e:
            processing_time = time.time() - start_time
            return ProcessingResult(
                filename=filename,
                success=False,
                error=str(e),
                processing_time=processing_time,
                model_used=self.model
            )

