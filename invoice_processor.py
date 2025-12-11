"""Invoice processing using OpenAI GPT-4 Vision API."""
import base64
import time
import json
from pathlib import Path
from typing import List
import fitz  # PyMuPDF

from openai import OpenAI

from config import settings
from models import InvoiceData, ProcessingResult


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
    
    def create_extraction_prompt(self) -> str:
        """Create the prompt for invoice data extraction."""
        return """You are an expert invoice data extractor. Analyze this invoice image and extract ALL items in a structured format.

Extract the following information:
1. Invoice metadata (number, date, vendor, customer, currency)
2. ALL line items with:
   - Item number/sequence
   - Description (exact text from invoice)
   - Quantity
   - Unit price
   - Total price (net amount/amount before tax)
   - Unit of measurement (if present)
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
      "unit": "string or null"
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
- If you cannot read an item with at least 85% confidence/accuracy, SKIP that item entirely
- Only include items where you are confident about all values (description, quantity, unit_price, total)

Important:
- Extract ONLY items you can read clearly and accurately (≥85% confidence)
- Keep descriptions exactly as they appear
- Use null for missing values
- Ensure all numbers are numeric types (not strings)
- ALWAYS validate: quantity × unit_price = total
- Return ONLY valid JSON, no additional text"""
    
    def process_with_openai(self, image_bytes: bytes) -> InvoiceData:
        """Process invoice using OpenAI GPT-4 Vision.
        
        Args:
            image_bytes: Image bytes of the invoice
            
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
                            "text": self.create_extraction_prompt()
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/png;base64,{base64_image}"
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
            
            if file_ext in ['.jpg', '.jpeg', '.png']:
                # Read image file directly
                with open(file_path, 'rb') as f:
                    image_bytes = f.read()
                images = [image_bytes]
            elif file_ext == '.pdf':
                # Convert PDF to images
                images = self.pdf_to_images(file_path, max_pages=1)  # Process first page
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
            
            # Process with OpenAI
            invoice_data = self.process_with_openai(images[0])
            
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

