"""
Small, import-friendly Google Document AI client wrapper.

Goal: given file bytes (PDF or image) return:
- raw Document AI document dict (optional)
- compact summary dict (invoice fields + line_items) with per-field confidences and raw mention_text
"""

from __future__ import annotations

import mimetypes
from typing import Any, Dict, List, Optional, Tuple

from google.cloud import documentai_v1 as documentai
from google.protobuf.json_format import MessageToDict


def guess_mime_from_name(filename: str) -> str:
    mime, _ = mimetypes.guess_type(filename)
    if mime:
        return mime
    lower = filename.lower()
    if lower.endswith(".pdf"):
        return "application/pdf"
    if lower.endswith(".png"):
        return "image/png"
    if lower.endswith(".jpg") or lower.endswith(".jpeg"):
        return "image/jpeg"
    if lower.endswith(".webp"):
        return "image/webp"
    if lower.endswith(".gif"):
        return "image/gif"
    return "application/octet-stream"


def _proto_to_dict(msg: Any) -> Dict[str, Any]:
    pb = getattr(msg, "_pb", msg)
    return MessageToDict(pb, preserving_proto_field_name=True)


def _ent_text(ent: Dict[str, Any]) -> Optional[str]:
    nv = ent.get("normalized_value") or {}
    if "text" in nv and nv.get("text"):
        return nv.get("text")
    if "float_value" in nv:
        return str(nv.get("float_value"))
    if "integer_value" in nv:
        return str(nv.get("integer_value"))
    return ent.get("mention_text") or ent.get("mentionText")


def extract_invoice_summary(document_dict: Dict[str, Any]) -> Dict[str, Any]:
    """
    Extract a compact invoice structure from Document AI output.
    Includes per-field confidence and raw mention text.
    """
    entities: List[Dict[str, Any]] = document_dict.get("entities") or []
    top: Dict[str, Any] = {}
    line_items: List[Dict[str, Any]] = []

    for ent in entities:
        etype = (ent.get("type_") or ent.get("type") or "").lower()

        if etype in {"invoice_id", "invoice_number"}:
            top["invoice_number"] = _ent_text(ent)
        elif etype in {"invoice_date"}:
            top["invoice_date"] = _ent_text(ent)
        elif etype in {"supplier_name", "vendor_name"}:
            top["vendor_name"] = _ent_text(ent)
        elif etype in {"customer_name", "receiver_name", "bill_to", "ship_to"}:
            top.setdefault("customer_name", _ent_text(ent))
        elif etype in {"total_amount", "invoice_total"}:
            top["total_amount"] = _ent_text(ent)
        elif etype in {"currency"}:
            top["currency"] = _ent_text(ent)
        elif etype == "line_item":
            item: Dict[str, Any] = {"raw_text": ent.get("mention_text") or ent.get("mentionText")}
            row_confidences: List[float] = []
            if ent.get("confidence") is not None:
                row_confidences.append(float(ent.get("confidence")))

            props: List[Dict[str, Any]] = ent.get("properties") or []
            for p in props:
                ptype = (p.get("type_") or p.get("type") or "").lower()
                raw = p.get("mention_text") or p.get("mentionText")
                val = _ent_text(p)
                conf = p.get("confidence")
                if conf is not None:
                    row_confidences.append(float(conf))

                if ptype.endswith("description"):
                    item["description"] = val
                    item["description_raw"] = raw
                    item["description_confidence"] = conf
                elif ptype.endswith("quantity"):
                    item["quantity"] = val
                    item["quantity_raw"] = raw
                    item["quantity_confidence"] = conf
                elif ptype.endswith("unit_price"):
                    item["unit_price"] = val
                    item["unit_price_raw"] = raw
                    item["unit_price_confidence"] = conf
                elif ptype.endswith("amount") or ptype.endswith("total"):
                    item["total"] = val
                    item["total_raw"] = raw
                    item["total_confidence"] = conf
                elif ptype.endswith("unit"):
                    item["unit"] = val
                    item["unit_raw"] = raw
                    item["unit_confidence"] = conf

            item["confidence"] = min(row_confidences) if row_confidences else ent.get("confidence")
            line_items.append(item)

    return {**top, "line_items": line_items}


def process_document_bytes(
    *,
    project_id: str,
    location: str,
    processor_id: str,
    processor_version_id: Optional[str],
    content: bytes,
    mime_type: str,
) -> Tuple[Dict[str, Any], Dict[str, Any]]:
    client = documentai.DocumentProcessorServiceClient()
    if processor_version_id:
        name = client.processor_version_path(project_id, location, processor_id, processor_version_id)
    else:
        name = client.processor_path(project_id, location, processor_id)

    raw_document = documentai.RawDocument(content=content, mime_type=mime_type)
    req = documentai.ProcessRequest(name=name, raw_document=raw_document)
    res = client.process_document(request=req)
    document_dict = _proto_to_dict(res.document)
    summary = extract_invoice_summary(document_dict)
    return document_dict, summary


