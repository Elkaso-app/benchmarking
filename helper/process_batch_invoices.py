#!/usr/bin/env python3
"""
Script to batch process invoices from helper/downloaded_invoices folder.
Processes the latest 100 unprocessed invoices and creates individual CSV files.
"""

import os
import sys
from pathlib import Path
from typing import List
import csv

# Add parent directory to path to import modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from invoice_processor import InvoiceProcessor
from models import ProcessingResult

# Configuration
INVOICES_DIR = Path(__file__).parent / "invoices/8576/input"
OUTPUT_DIR = Path(__file__).parent / "invoices/8576/output"
MAX_INVOICES = 100


def ensure_output_directory():
    """Create output directory if it doesn't exist."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"✅ Output directory: {OUTPUT_DIR}")


def get_invoice_files() -> List[Path]:
    """Get all invoice files sorted by name (descending - latest first)."""
    if not INVOICES_DIR.exists():
        print(f"❌ Error: Directory not found: {INVOICES_DIR}")
        return []
    
    # Get all image and PDF files
    files = []
    for ext in ['*.jpg', '*.jpeg', '*.png', '*.pdf']:
        files.extend(INVOICES_DIR.glob(ext))
    
    # Sort by filename descending (latest first: 2963847_2.jpg > 2711139_1.jpg)
    files.sort(reverse=True, key=lambda x: x.name)
    
    return files


def get_output_csv_path(invoice_path: Path) -> Path:
    """Get the output CSV path for an invoice."""
    # Remove extension and add .csv
    csv_name = invoice_path.stem + ".csv"
    return OUTPUT_DIR / csv_name


def is_already_processed(invoice_path: Path) -> bool:
    """Check if invoice has already been processed (CSV exists)."""
    csv_path = get_output_csv_path(invoice_path)
    return csv_path.exists()


def write_invoice_csv(result: ProcessingResult, output_path: Path):
    """Write processing result to individual CSV file (clean format - items only)."""
    if not result.success or not result.invoice_data:
        # Create empty CSV with error message
        with open(output_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['Status', 'Error', 'Filename'])
            writer.writerow(['Failed', result.error or 'Unknown error', result.filename])
        return
    
    # Write successful extraction to CSV (clean format - items only)
    invoice = result.invoice_data
    
    with open(output_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        
        # Header row
        writer.writerow(['Item #', 'Description', 'Quantity', 'Unit', 'Unit Price', 'Total'])
        
        # Items data
        for item in invoice.items:
            writer.writerow([
                item.item_number or '',
                item.description or '',
                item.quantity or '',
                item.unit or '',
                item.unit_price or '',
                item.total or ''
            ])


def process_invoices():
    """Main function to process invoices."""
    print("🚀 Invoice Batch Processor")
    print("=" * 60)
    
    ensure_output_directory()
    
    # Get all invoice files
    all_invoices = get_invoice_files()
    print(f"📄 Found {len(all_invoices)} total invoice files")
    
    if not all_invoices:
        print("❌ No invoice files found!")
        return
    
    # Filter out already processed invoices
    unprocessed = [inv for inv in all_invoices if not is_already_processed(inv)]
    print(f"📋 Unprocessed invoices: {len(unprocessed)}")
    
    # Limit to MAX_INVOICES
    to_process = unprocessed[:MAX_INVOICES]
    skipped_count = len(all_invoices) - len(unprocessed)
    
    print(f"⚡ Will process: {len(to_process)} invoices")
    print(f"⏭️  Skipped (already processed): {skipped_count}")
    print("=" * 60)
    
    if not to_process:
        print("✅ All invoices are already processed!")
        return
    
    # Initialize processor
    processor = InvoiceProcessor()
    
    # Process each invoice
    successful = 0
    failed = 0
    
    for idx, invoice_path in enumerate(to_process, 1):
        print(f"\n[{idx}/{len(to_process)}] Processing: {invoice_path.name}")
        
        try:
            # Process invoice
            result = processor.process_invoice(invoice_path)
            
            # Get output CSV path
            output_csv = get_output_csv_path(invoice_path)
            
            # Write to CSV
            write_invoice_csv(result, output_csv)
            
            if result.success:
                items_count = len(result.invoice_data.items) if result.invoice_data else 0
                print(f"   ✅ Success! Extracted {items_count} items ({result.processing_time:.2f}s)")
                print(f"   📄 CSV: {output_csv.name}")
                successful += 1
            else:
                print(f"   ❌ Failed: {result.error}")
                print(f"   📄 CSV: {output_csv.name} (error logged)")
                failed += 1
                
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
            failed += 1
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 PROCESSING SUMMARY")
    print("=" * 60)
    print(f"Total Processed: {len(to_process)}")
    print(f"✅ Successful: {successful}")
    print(f"❌ Failed: {failed}")
    print(f"📁 Output Directory: {OUTPUT_DIR}")
    print("=" * 60)


if __name__ == "__main__":
    try:
        process_invoices()
        print("\n✨ Processing complete!")
    except KeyboardInterrupt:
        print("\n\n⚠️  Processing interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Fatal error: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
