#!/usr/bin/env python3
"""
Merge all invoice CSVs from helper/output/ into one big CSV in helper/merge/
"""

import csv
from pathlib import Path
from datetime import datetime


def merge_invoices():
    """Merge all individual invoice CSVs into one master CSV."""
    
    # Setup paths
    script_dir = Path(__file__).parent
    output_dir = script_dir / "invoices/8576/output"
    merge_dir = script_dir / "invoices/8576/merge"
    
    # Create merge directory
    merge_dir.mkdir(exist_ok=True)
    
    # Output file with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    merged_file = merge_dir / f"merged_invoices_{timestamp}.csv"
    
    # Get all CSV files
    csv_files = sorted(output_dir.glob("*.csv"))
    
    if not csv_files:
        print(f"❌ No CSV files found in {output_dir}")
        return
    
    print(f"📊 Found {len(csv_files)} invoice CSV files")
    print(f"🔄 Merging into: {merged_file.name}\n")
    
    # Counters
    total_items = 0
    processed_files = 0
    
    # Write merged CSV
    with open(merged_file, 'w', newline='', encoding='utf-8') as outfile:
        writer = csv.writer(outfile)
        
        # Write header with additional "Invoice File" column
        writer.writerow(['Invoice File', 'Item #', 'Description', 'Quantity', 'Unit', 'Unit Price', 'Total'])
        
        # Process each CSV
        for csv_file in csv_files:
            try:
                with open(csv_file, 'r', encoding='utf-8') as infile:
                    reader = csv.reader(infile)
                    
                    # Skip header row
                    header = next(reader, None)
                    
                    # Get invoice filename (without extension)
                    invoice_name = csv_file.stem
                    
                    # Write all items with invoice filename prepended
                    file_items = 0
                    for row in reader:
                        if row:  # Skip empty rows
                            writer.writerow([invoice_name] + row)
                            file_items += 1
                            total_items += 1
                    
                    processed_files += 1
                    print(f"✅ {invoice_name}.csv - {file_items} items")
                    
            except Exception as e:
                print(f"❌ Error processing {csv_file.name}: {e}")
    
    # Summary
    print(f"\n{'='*60}")
    print(f"✨ Merge Complete!")
    print(f"{'='*60}")
    print(f"📁 Processed Files: {processed_files}")
    print(f"📊 Total Items: {total_items}")
    print(f"💾 Output: {merged_file}")
    print(f"📂 Location: {merge_dir}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    merge_invoices()

