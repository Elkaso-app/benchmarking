#!/usr/bin/env python3
"""
Run Google Document AI on a folder, then send DocAI line-items to Claude to "clean" them.

Outputs per input file:
- <name>_docai_raw.json      (full Document AI document)
- <name>_docai_summary.json  (compact summary with per-field confidence + raw text)
- <name>_cleaned.json        (cleaned items, net totals, inferred qty/price)
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from typing import Any, Dict, List

from dotenv import load_dotenv

# ensure imports work when running as a script
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent))

from config import settings
from invoice_processor import InvoiceProcessor
from docai_client import process_document_bytes, guess_mime_from_name


def _write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")


def main() -> None:
    load_dotenv()

    p = argparse.ArgumentParser()
    p.add_argument("--in", dest="in_dir", default="todo/test/in", help="Input folder")
    p.add_argument("--out", dest="out_dir", default="todo/test/out", help="Output folder")
    args = p.parse_args()

    in_dir = Path(args.in_dir).expanduser().resolve()
    out_dir = Path(args.out_dir).expanduser().resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    project_id = settings.google_cloud_project or os.getenv("GOOGLE_CLOUD_PROJECT") or os.getenv("GCP_PROJECT") or ""
    location = settings.docai_location or os.getenv("DOCAI_LOCATION", "us")
    processor_id = settings.docai_processor_id or os.getenv("DOCAI_PROCESSOR_ID") or ""
    processor_version_id = settings.docai_processor_version_id or os.getenv("DOCAI_PROCESSOR_VERSION_ID") or None

    if not project_id or not processor_id:
        raise SystemExit("Missing Document AI config. Set GOOGLE_CLOUD_PROJECT and DOCAI_PROCESSOR_ID in .env.")

    processor = InvoiceProcessor()

    files = sorted([p for p in in_dir.iterdir() if p.is_file()])
    if not files:
        print(f"No files found in {in_dir}")
        return

    for fp in files:
        print(f"\n📄 {fp.name}")
        content = fp.read_bytes()
        mime = guess_mime_from_name(fp.name)

        raw_doc, summary = process_document_bytes(
            project_id=project_id,
            location=location,
            processor_id=processor_id,
            processor_version_id=processor_version_id,
            content=content,
            mime_type=mime,
        )

        base = fp.stem
        _write_json(out_dir / f"{base}_docai_raw.json", raw_doc)
        _write_json(out_dir / f"{base}_docai_summary.json", summary)

        cleaned_items: List[Dict[str, Any]] = []
        for gi in (summary.get("line_items") or []):
            if not (gi.get("description") or gi.get("description_raw")):
                continue
            cleaned = processor.clean_item_from_docai_line_item(gi)
            if cleaned is None:
                continue
            cleaned_items.append(
                {
                    "description": cleaned.description,
                    "unit": cleaned.unit,
                    "quantity": cleaned.quantity,
                    "unit_price": cleaned.unit_price,
                    "total": cleaned.total,
                    "llm_confidence": cleaned.llm_confidence,
                    "google_json": gi,
                }
            )

        _write_json(out_dir / f"{base}_cleaned.json", {"items": cleaned_items})
        print(f"✅ cleaned items: {len(cleaned_items)}")


if __name__ == "__main__":
    main()


