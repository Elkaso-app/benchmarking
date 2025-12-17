"""
Google Cloud Document AI - INVOICE_PROCESSOR quick tester.

This script is intentionally standalone (does NOT change your existing LLM pipeline).

Prereqs:
  - Enable Document AI API in your GCP project.
  - Authenticate with Application Default Credentials (ADC), one of:
      - gcloud auth application-default login
      - export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json

Usage examples:
  - Process a local PDF:
      python helper/docai_invoice_processor.py \
        --project cohesive-amp-436709-n8 \
        --location us \
        --processor-id YOUR_PROCESSOR_ID \
        --file /path/to/invoice.pdf \
        --out helper/docai_out.json

  - Process using a specific processor *version* (e.g. pretrained invoice v2):
      python helper/docai_invoice_processor.py \
        --project cohesive-amp-436709-n8 \
        --location us \
        --processor-id YOUR_PROCESSOR_ID \
        --processor-version-id pretrained-invoice-v2.0-2023-12-06 \
        --file /path/to/invoice.pdf

  - Process from a URL (S3, etc):
      python helper/docai_invoice_processor.py \
        --project cohesive-amp-436709-n8 \
        --location us \
        --processor-id YOUR_PROCESSOR_ID \
        --url "https://example.com/invoice.jpg"
"""

from __future__ import annotations

import argparse
import json
import mimetypes
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import requests
from google.cloud import documentai_v1 as documentai
from google.protobuf.json_format import MessageToDict

# Import global settings
import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent))
from config import settings


@dataclass(frozen=True)
class InputDoc:
    content: bytes
    mime_type: str
    source_name: str


def _guess_mime(path_or_name: str) -> Optional[str]:
    mime, _ = mimetypes.guess_type(path_or_name)
    if mime:
        return mime
    lower = path_or_name.lower()
    if lower.endswith(".pdf"):
        return "application/pdf"
    return None


def _load_from_file(file_path: str, mime_type: Optional[str]) -> InputDoc:
    p = Path(file_path).expanduser().resolve()
    content = p.read_bytes()
    mt = mime_type or _guess_mime(p.name) or "application/octet-stream"
    return InputDoc(content=content, mime_type=mt, source_name=str(p))


def _load_from_url(url: str, mime_type: Optional[str]) -> InputDoc:
    resp = requests.get(url, timeout=60)
    resp.raise_for_status()
    name_hint = url.split("?")[0].split("/")[-1] or "remote"
    mt = mime_type or resp.headers.get("Content-Type") or _guess_mime(name_hint) or "application/octet-stream"
    # strip charset if present, e.g. "application/pdf; charset=utf-8"
    mt = mt.split(";")[0].strip()
    return InputDoc(content=resp.content, mime_type=mt, source_name=url)


def _document_to_dict(doc: Any) -> Dict[str, Any]:
    # documentai returns a protobuf message; sometimes wrapped.
    msg = getattr(doc, "_pb", doc)
    return MessageToDict(msg, preserving_proto_field_name=True)


def _extract_invoice_summary(document_dict: Dict[str, Any]) -> Dict[str, Any]:
    """
    Best-effort extraction from Document AI "entities" into a compact summary.
    We keep it very defensive because entity schemas vary by version.
    """
    entities: List[Dict[str, Any]] = document_dict.get("entities") or []
    top: Dict[str, Any] = {}
    line_items: List[Dict[str, Any]] = []

    def ent_text(ent: Dict[str, Any]) -> Optional[str]:
        # entity may have normalizedValue or mentionText
        if "normalized_value" in ent:
            nv = ent.get("normalized_value") or {}
            if "text" in nv:
                return nv.get("text")
            if "float_value" in nv:
                return str(nv.get("float_value"))
            if "integer_value" in nv:
                return str(nv.get("integer_value"))
            if "money_value" in nv:
                mv = nv.get("money_value") or {}
                return f"{mv.get('currency_code', '')} {mv.get('units', 0)}.{mv.get('nanos', 0)}"
        return ent.get("mention_text") or ent.get("mentionText")

    for ent in entities:
        # Document AI sometimes uses "type" and sometimes "type_" depending on proto-to-dict conversion
        etype = (ent.get("type_") or ent.get("type") or "").lower()
        
        if etype in {"invoice_id", "invoice_number"}:
            top["invoice_number"] = ent_text(ent)
        elif etype in {"invoice_date"}:
            top["invoice_date"] = ent_text(ent)
        elif etype in {"supplier_name", "vendor_name"}:
            top["vendor_name"] = ent_text(ent)
        elif etype in {"customer_name", "receiver_name", "bill_to", "ship_to"}:
            top.setdefault("customer_name", ent_text(ent))
        elif etype in {"total_amount", "invoice_total"}:
            top["total_amount"] = ent_text(ent)
        elif etype in {"currency"}:
            top["currency"] = ent_text(ent)
        elif etype == "line_item":
            item: Dict[str, Any] = {
                "raw_text": ent.get("mention_text") or ent.get("mentionText")
            }
            row_confidences = []
            if ent.get("confidence") is not None:
                row_confidences.append(float(ent.get("confidence")))

            props: List[Dict[str, Any]] = ent.get("properties") or []
            for p in props:
                ptype = (p.get("type_") or p.get("type") or "").lower()
                field_val = ent_text(p)
                field_raw = p.get("mention_text") or p.get("mentionText")
                field_conf = p.get("confidence")
                
                if field_conf is not None:
                    row_confidences.append(float(field_conf))

                # Mapping fields
                if ptype.endswith("description"):
                    item["description"] = field_val
                    item["description_raw"] = field_raw
                    item["description_confidence"] = field_conf
                elif ptype.endswith("quantity"):
                    item["quantity"] = field_val
                    item["quantity_raw"] = field_raw
                    item["quantity_confidence"] = field_conf
                elif ptype.endswith("unit_price"):
                    item["unit_price"] = field_val
                    item["unit_price_raw"] = field_raw
                    item["unit_price_confidence"] = field_conf
                elif ptype.endswith("amount") or ptype.endswith("total"):
                    item["total"] = field_val
                    item["total_raw"] = field_raw
                    item["total_confidence"] = field_conf
                elif ptype.endswith("unit"):
                    item["unit"] = field_val
                    item["unit_raw"] = field_raw
                    item["unit_confidence"] = field_conf
            
            # Use the minimum confidence found in the row properties for the overall row confidence
            item["confidence"] = min(row_confidences) if row_confidences else ent.get("confidence")
            line_items.append(item)

    return {**top, "line_items": line_items}


def process_with_document_ai(
    *,
    project_id: str,
    location: str,
    processor_id: str,
    processor_version_id: Optional[str],
    input_doc: InputDoc,
) -> Tuple[Dict[str, Any], Dict[str, Any]]:
    client = documentai.DocumentProcessorServiceClient()

    if processor_version_id:
        name = client.processor_version_path(project_id, location, processor_id, processor_version_id)
    else:
        name = client.processor_path(project_id, location, processor_id)

    raw_document = documentai.RawDocument(content=input_doc.content, mime_type=input_doc.mime_type)
    request = documentai.ProcessRequest(name=name, raw_document=raw_document)
    result = client.process_document(request=request)

    document_dict = _document_to_dict(result.document)
    summary = _extract_invoice_summary(document_dict)
    return document_dict, summary


def _parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Test Google Document AI INVOICE_PROCESSOR on a file or URL.")
    p.add_argument("--project", default=settings.google_cloud_project or os.getenv("GOOGLE_CLOUD_PROJECT") or os.getenv("GCP_PROJECT") or "", help="GCP project id")
    p.add_argument("--location", default=settings.docai_location, help="Processor location, e.g. us or eu")
    p.add_argument("--processor-id", default=settings.docai_processor_id, help="Document AI processor id")
    p.add_argument(
        "--processor-version-id",
        default=settings.docai_processor_version_id,
        help="Optional processor version id (e.g. pretrained-invoice-v2.0-2023-12-06)",
    )

    src = p.add_mutually_exclusive_group(required=True)
    src.add_argument("--file", help="Local file path (pdf/jpg/png/...)")
    src.add_argument("--url", help="Remote URL to download (pdf/jpg/png/...)")

    p.add_argument("--mime-type", default="", help="Override mime type (e.g. application/pdf, image/jpeg)")
    p.add_argument("--out", default="", help="Write raw Document AI JSON to this path (default: print)")
    p.add_argument("--summary-out", default="", help="Write compact summary JSON to this path (default: print)")
    return p.parse_args()


def main() -> None:
    args = _parse_args()

    if not args.project:
        raise SystemExit("Missing --project (or set GOOGLE_CLOUD_PROJECT).")
    if not args.processor_id:
        raise SystemExit("Missing --processor-id (or set DOCAI_PROCESSOR_ID).")

    processor_version_id = args.processor_version_id.strip() or None
    mime_override = args.mime_type.strip() or None

    if args.file:
        input_doc = _load_from_file(args.file, mime_override)
    else:
        input_doc = _load_from_url(args.url, mime_override)

    document_dict, summary = process_with_document_ai(
        project_id=args.project,
        location=args.location,
        processor_id=args.processor_id,
        processor_version_id=processor_version_id,
        input_doc=input_doc,
    )

    if args.out:
        out_path = Path(args.out).expanduser().resolve()
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(document_dict, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"Wrote raw Document AI JSON: {out_path}")
    else:
        print(json.dumps(document_dict, indent=2, ensure_ascii=False))

    if args.summary_out:
        out_path = Path(args.summary_out).expanduser().resolve()
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"Wrote summary JSON: {out_path}")
    else:
        # If printing raw doc to stdout, don't spam summary too; only print if raw doc was written to file.
        if args.out:
            print("\n--- Summary (best-effort) ---")
            print(json.dumps(summary, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()


