#!/usr/bin/env python3
"""
Process restaurant orders from database and extract invoice items using GPT-4 Vision.

This script:
1. Connects to PostgreSQL database
2. Queries orders for specific restaurant_id + date range
3. Filters orders NOT already processed
4. Downloads invoice images from S3
5. Processes each invoice with LLM
6. Inserts all items from all invoices (transaction: all-or-nothing per order)
7. Supports parallel processing for faster execution
"""

import os
import sys
import psycopg2
from psycopg2 import sql
from psycopg2.extras import execute_batch
import requests
import tempfile
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor, as_completed
from dotenv import load_dotenv

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from invoice_processor import InvoiceProcessor
from models import InvoiceData, InvoiceItem

# Load environment variables
load_dotenv()

# ==================== CONFIGURATION ====================

# Restaurant and date filter
RESTAURANT_IDS = [8296, 8446,7372,8290,8136,8355,6150,8576,8193,8178,6975,5750,8828,7503]  # List of restaurant IDs to process
START_DATE = '2025-10-01 00:00:00'

# Processing limits
MAX_ORDERS_PER_RUN = 10000
MAX_PARALLEL_ORDERS = 50  # Process up to 4 orders concurrently

# Database connection
DB_CONFIG = {
    'host': os.getenv('LOCAL_DB_HOST'),
    'port': os.getenv('LOCAL_DB_PORT', 5432),
    'database': os.getenv('LOCAL_DB_NAME'),
    'user': os.getenv('LOCAL_DB_USER'),
    'password': os.getenv('LOCAL_DB_PASSWORD'),
}

# Request settings
REQUEST_TIMEOUT = 30
MAX_IMAGE_SIZE_MB = 20

# ==================== DATABASE FUNCTIONS ====================

def get_db_connection():
    """Create and return a database connection."""
    return psycopg2.connect(**DB_CONFIG)


def fetch_unprocessed_orders(conn) -> List[Dict]:
    """
    Fetch orders that haven't been processed yet.
    
    Returns:
        List of dicts with keys: order_id, invoice_image, created_at
    """
    query = """
    SELECT 
        o.order_id,
        o.invoice_image,
        o.created_at
    FROM benchmarking.orders o
    WHERE 
        o.restaurant_id = ANY(%s)
        AND o.created_at >= %s
        AND o.invoice_image IS NOT NULL
        AND array_length(o.invoice_image, 1) > 0
        AND NOT EXISTS (
            SELECT 1 
            FROM benchmarking.invoice_items ii 
            WHERE ii.order_id = o.order_id
        )
    ORDER BY o.created_at DESC
    LIMIT %s
    """
    
    with conn.cursor() as cur:
        cur.execute(query, (RESTAURANT_IDS, START_DATE, MAX_ORDERS_PER_RUN))
        columns = [desc[0] for desc in cur.description]
        results = [dict(zip(columns, row)) for row in cur.fetchall()]
    
    return results


def insert_invoice_items(conn, order_id: int, items: List[InvoiceItem], llm_model: str) -> int:
    """
    Insert invoice items for an order in a transaction.
    
    Args:
        conn: Database connection
        order_id: Order ID
        items: List of InvoiceItem objects
        llm_model: LLM model name
        
    Returns:
        Number of items inserted
    """
    if not items:
        return 0
    
    insert_query = """
    INSERT INTO benchmarking.invoice_items 
        (order_id, item_name, qty, uom, unit_price, net_price, llm, created_at, updated_at)
    VALUES 
        (%s, %s, %s, %s, %s, %s, %s, NOW(), NOW())
    ON CONFLICT (order_id, item_name, qty, uom, unit_price, net_price) 
    DO NOTHING
    """
    
    values = []
    for item in items:
        values.append((
            order_id,
            item.description or '',
            float(item.quantity) if item.quantity else None,
            item.unit or '',
            float(item.unit_price) if item.unit_price else None,
            float(item.total) if item.total else None,
            llm_model,
        ))
    
    with conn.cursor() as cur:
        execute_batch(cur, insert_query, values)
        conn.commit()
    
    return len(values)


# ==================== IMAGE PROCESSING ====================

def download_file_from_s3(url: str) -> Optional[Tuple[bytes, str]]:
    """
    Download file from S3 URL (supports both images and PDFs).
    
    Args:
        url: S3 URL
        
    Returns:
        Tuple of (file_bytes, extension) or None if failed
    """
    try:
        response = requests.get(url, timeout=REQUEST_TIMEOUT)
        response.raise_for_status()
        
        # Check size
        content_length = len(response.content)
        if content_length > MAX_IMAGE_SIZE_MB * 1024 * 1024:
            print(f"  ⚠️  File too large: {content_length / 1024 / 1024:.1f}MB")
            return None
        
        # Determine file extension from URL or content-type
        extension = 'jpg'  # default
        url_lower = url.lower()
        
        if '.pdf' in url_lower or url.endswith('.pdf'):
            extension = 'pdf'
        elif '.png' in url_lower:
            extension = 'png'
        elif '.jpeg' in url_lower or '.jpg' in url_lower:
            extension = 'jpg'
        elif '.webp' in url_lower:
            extension = 'webp'
        elif '.gif' in url_lower:
            extension = 'gif'
        else:
            # Try to detect from content-type header
            content_type = response.headers.get('content-type', '').lower()
            if 'pdf' in content_type:
                extension = 'pdf'
            elif 'png' in content_type:
                extension = 'png'
            elif 'jpeg' in content_type or 'jpg' in content_type:
                extension = 'jpg'
            elif 'webp' in content_type:
                extension = 'webp'
            elif 'gif' in content_type:
                extension = 'gif'
        
        return (response.content, extension)
        
    except Exception as e:
        print(f"  ❌ Download failed: {e}")
        return None


def save_temp_file(file_bytes: bytes, extension: str = 'jpg') -> Optional[Path]:
    """
    Save file bytes to temporary file.
    
    Args:
        file_bytes: File bytes (image or PDF)
        extension: File extension
        
    Returns:
        Path to temp file or None if failed
    """
    try:
        temp_file = tempfile.NamedTemporaryFile(
            delete=False, 
            suffix=f'.{extension}'
        )
        temp_file.write(file_bytes)
        temp_file.close()
        return Path(temp_file.name)
    except Exception as e:
        print(f"  ❌ Failed to save temp file: {e}")
        return None


def parse_invoice_urls(invoice_image_array: List[str]) -> List[str]:
    """
    Parse invoice URLs from PostgreSQL array.
    
    Args:
        invoice_image_array: List of URLs from database
        
    Returns:
        List of clean URLs
    """
    if not invoice_image_array:
        return []
    
    # Filter out empty strings and None
    return [url for url in invoice_image_array if url and url.strip()]


# ==================== ORDER PROCESSING ====================

def process_single_order(
    order: Dict, 
    processor: InvoiceProcessor
) -> Tuple[int, int, Optional[str]]:
    """
    Process a single order with all its invoices.
    
    Args:
        order: Order dict with order_id, invoice_image, created_at
        processor: InvoiceProcessor instance
        
    Returns:
        Tuple of (order_id, items_count, error_message)
    """
    order_id = order['order_id']
    invoice_urls = parse_invoice_urls(order['invoice_image'])
    
    print(f"\n📦 Processing Order #{order_id}")
    print(f"   Created: {order['created_at']}")
    print(f"   Invoices: {len(invoice_urls)}")
    
    if not invoice_urls:
        return (order_id, 0, "No invoice images found")
    
    all_items = []
    temp_files = []
    
    try:
        # Process each invoice
        for idx, url in enumerate(invoice_urls, 1):
            print(f"   📄 Invoice {idx}/{len(invoice_urls)}: {url[:80]}...")
            
            # Download file (image or PDF)
            result = download_file_from_s3(url)
            if not result:
                return (order_id, 0, f"Failed to download invoice {idx}")
            
            file_bytes, extension = result
            print(f"      📎 File type: {extension.upper()}")
            
            # Save to temp file
            temp_path = save_temp_file(file_bytes, extension)
            if not temp_path:
                return (order_id, 0, f"Failed to save invoice {idx} to temp file")
            
            temp_files.append(temp_path)
            
            # Process with LLM
            print(f"      🤖 Processing with {processor.model}...")
            result = processor.process_invoice(temp_path)
            
            if not result.success:
                error_msg = result.error or "Unknown error"
                return (order_id, 0, f"LLM processing failed for invoice {idx}: {error_msg}")
            
            if not result.invoice_data or not result.invoice_data.items:
                print(f"      ⚠️  No items extracted from invoice {idx}")
                continue
            
            items_count = len(result.invoice_data.items)
            print(f"      ✅ Extracted {items_count} items")
            all_items.extend(result.invoice_data.items)
        
        # Check if we got any items
        if not all_items:
            return (order_id, 0, "No items extracted from any invoice")
        
        # Insert all items in database
        print(f"   💾 Inserting {len(all_items)} items to database...")
        conn = get_db_connection()
        try:
            inserted_count = insert_invoice_items(
                conn, 
                order_id, 
                all_items, 
                processor.model
            )
            print(f"   ✅ Order #{order_id} complete: {inserted_count} items inserted")
            return (order_id, inserted_count, None)
        finally:
            conn.close()
    
    except Exception as e:
        error_msg = f"Unexpected error: {str(e)}"
        print(f"   ❌ {error_msg}")
        return (order_id, 0, error_msg)
    
    finally:
        # Clean up temp files
        for temp_file in temp_files:
            try:
                if temp_file.exists():
                    temp_file.unlink()
            except:
                pass


# ==================== MAIN EXECUTION ====================

def main():
    """Main execution function."""
    print("=" * 80)
    print("🚀 Invoice Items Extraction from Database")
    print("=" * 80)
    print(f"\n📊 Configuration:")
    print(f"   Restaurant IDs: {RESTAURANT_IDS}")
    print(f"   Start Date: {START_DATE}")
    print(f"   Max Orders: {MAX_ORDERS_PER_RUN}")
    print(f"   Parallel Workers: {MAX_PARALLEL_ORDERS}")
    print(f"   Database: {DB_CONFIG['database']}@{DB_CONFIG['host']}")
    
    # Initialize processor
    print(f"\n🤖 Initializing InvoiceProcessor...")
    processor = InvoiceProcessor()
    print(f"   Model: {processor.model}")
    
    # Connect to database
    print(f"\n🔌 Connecting to database...")
    try:
        conn = get_db_connection()
        print(f"   ✅ Connected successfully")
    except Exception as e:
        print(f"   ❌ Database connection failed: {e}")
        return
    
    # Fetch unprocessed orders
    print(f"\n🔍 Fetching unprocessed orders...")
    try:
        orders = fetch_unprocessed_orders(conn)
        print(f"   ✅ Found {len(orders)} orders to process")
    except Exception as e:
        print(f"   ❌ Failed to fetch orders: {e}")
        conn.close()
        return
    finally:
        conn.close()
    
    if not orders:
        print(f"\n✨ No orders to process!")
        return
    
    # Process orders in parallel
    print(f"\n{'=' * 80}")
    print(f"📦 Processing {len(orders)} orders...")
    print(f"{'=' * 80}")
    
    start_time = datetime.now()
    results = {
        'success': 0,
        'failed': 0,
        'total_items': 0,
        'errors': []
    }
    
    with ThreadPoolExecutor(max_workers=MAX_PARALLEL_ORDERS) as executor:
        # Submit all orders
        futures = {
            executor.submit(process_single_order, order, processor): order
            for order in orders
        }
        
        # Process results as they complete
        for future in as_completed(futures):
            order = futures[future]
            try:
                order_id, items_count, error = future.result()
                
                if error:
                    results['failed'] += 1
                    results['errors'].append({
                        'order_id': order_id,
                        'error': error
                    })
                else:
                    results['success'] += 1
                    results['total_items'] += items_count
            
            except Exception as e:
                results['failed'] += 1
                results['errors'].append({
                    'order_id': order['order_id'],
                    'error': f"Exception: {str(e)}"
                })
    
    # Print summary
    duration = datetime.now() - start_time
    print(f"\n{'=' * 80}")
    print(f"✨ Processing Complete!")
    print(f"{'=' * 80}")
    print(f"\n📊 Summary:")
    print(f"   ✅ Successful: {results['success']} orders")
    print(f"   ❌ Failed: {results['failed']} orders")
    print(f"   📦 Total Items: {results['total_items']} items")
    print(f"   ⏱️  Duration: {duration}")
    print(f"   ⚡ Rate: {len(orders) / duration.total_seconds():.2f} orders/sec")
    
    if results['errors']:
        print(f"\n❌ Failed Orders:")
        for error in results['errors'][:10]:  # Show first 10 errors
            print(f"   Order #{error['order_id']}: {error['error']}")
        if len(results['errors']) > 10:
            print(f"   ... and {len(results['errors']) - 10} more errors")
    
    print(f"\n{'=' * 80}\n")


if __name__ == "__main__":
    main()
