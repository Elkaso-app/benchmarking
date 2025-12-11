#!/usr/bin/env python3
"""
Script to download invoices from CSV file
Reads helper/invoices.csv and downloads all invoice images
Saves them to helper/downloaded_invoices/
"""

import csv
import os
import requests
from pathlib import Path
from urllib.parse import urlparse
import time

# Configuration
CSV_PATH = "helper/invoices.csv"
OUTPUT_DIR = "helper/downloaded_invoices"
REQUEST_TIMEOUT = 30
RETRY_COUNT = 3
DELAY_BETWEEN_REQUESTS = 0.5  # seconds

def ensure_output_directory():
    """Create output directory if it doesn't exist"""
    Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)
    print(f"✅ Output directory: {OUTPUT_DIR}")

def parse_invoice_urls(invoice_image_field):
    """
    Parse the invoice_image field to extract URLs
    Input: "{url1,url2,url3}" or "{url1}"
    Output: ["url1", "url2", "url3"]
    """
    # Remove curly braces and split by comma
    cleaned = invoice_image_field.strip().strip('{}')
    urls = [url.strip() for url in cleaned.split(',')]
    return urls

def get_file_extension(url):
    """Extract file extension from URL"""
    parsed = urlparse(url)
    path = parsed.path
    ext = os.path.splitext(path)[1]
    return ext if ext else '.jpg'  # default to .jpg if no extension

def download_image(url, output_path, retries=RETRY_COUNT):
    """Download image from URL with retry logic"""
    for attempt in range(retries):
        try:
            response = requests.get(url, timeout=REQUEST_TIMEOUT, stream=True)
            response.raise_for_status()
            
            with open(output_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            return True
        except Exception as e:
            if attempt < retries - 1:
                print(f"   ⚠️  Attempt {attempt + 1} failed, retrying... ({str(e)})")
                time.sleep(1)
            else:
                print(f"   ❌ Failed after {retries} attempts: {str(e)}")
                return False
    return False

def process_csv():
    """Main function to process CSV and download all invoices"""
    ensure_output_directory()
    
    if not os.path.exists(CSV_PATH):
        print(f"❌ Error: CSV file not found at {CSV_PATH}")
        return
    
    print(f"📄 Reading CSV file: {CSV_PATH}")
    
    with open(CSV_PATH, 'r', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        
        total_rows = 0
        total_images = 0
        successful_downloads = 0
        failed_downloads = 0
        
        for row in reader:
            total_rows += 1
            invoice_id = row['id']
            invoice_image_field = row['invoice_image']
            
            # Parse URLs from the invoice_image field
            urls = parse_invoice_urls(invoice_image_field)
            total_images += len(urls)
            
            print(f"\n📋 Processing Invoice ID: {invoice_id} ({len(urls)} image(s))")
            
            for idx, url in enumerate(urls, start=1):
                # Get file extension from URL
                ext = get_file_extension(url)
                
                # Create filename: id_1.jpg, id_2.jpg, etc.
                filename = f"{invoice_id}_{idx}{ext}"
                output_path = os.path.join(OUTPUT_DIR, filename)
                
                # Skip if already downloaded
                if os.path.exists(output_path):
                    file_size = os.path.getsize(output_path)
                    print(f"   ⏭️  [{idx}/{len(urls)}] Already exists: {filename} ({file_size:,} bytes)")
                    successful_downloads += 1
                    continue
                
                print(f"   ⬇️  [{idx}/{len(urls)}] Downloading: {filename}")
                
                if download_image(url, output_path):
                    file_size = os.path.getsize(output_path)
                    print(f"   ✅ [{idx}/{len(urls)}] Saved: {filename} ({file_size:,} bytes)")
                    successful_downloads += 1
                else:
                    print(f"   ❌ [{idx}/{len(urls)}] Failed: {filename}")
                    failed_downloads += 1
                
                # Small delay to avoid overwhelming the server
                time.sleep(DELAY_BETWEEN_REQUESTS)
    
    # Summary
    print("\n" + "="*60)
    print("📊 DOWNLOAD SUMMARY")
    print("="*60)
    print(f"Total Invoice Records: {total_rows}")
    print(f"Total Images: {total_images}")
    print(f"✅ Successful Downloads: {successful_downloads}")
    print(f"❌ Failed Downloads: {failed_downloads}")
    print(f"📁 Output Directory: {OUTPUT_DIR}")
    print("="*60)

if __name__ == "__main__":
    print("🚀 Invoice Downloader Script")
    print("="*60)
    
    try:
        process_csv()
        print("\n✨ Script completed!")
    except KeyboardInterrupt:
        print("\n\n⚠️  Script interrupted by user")
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
