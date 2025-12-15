# Quick Start: Database Order Processing

## 🚀 Run the Script

```bash
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking
source venv/bin/activate
python helper/process_db_orders.py
```

## ⚙️ Configuration (Edit in script)

```python
# In helper/process_db_orders.py

RESTAURANT_ID = 8178                # Which restaurant to process
START_DATE = '2025-10-01 00:00:00'  # Start date filter
MAX_ORDERS_PER_RUN = 100            # How many orders per run
MAX_PARALLEL_ORDERS = 4             # Concurrent processing (adjust for speed vs rate limits)
```

## 📋 What It Does

1. ✅ Connects to PostgreSQL database
2. ✅ Queries unprocessed orders for restaurant #8178 (since Oct 1, 2025)
3. ✅ Downloads invoice images from S3
4. ✅ Processes with GPT-4o-2024-11-20
5. ✅ Extracts items (name, qty, unit, price, total)
6. ✅ Inserts to `benchmarking.invoice_items` table
7. ✅ Only inserts if ALL invoices succeed (transaction safety)
8. ✅ Skips already-processed orders

## 📊 Expected Output

```
🚀 Invoice Items Extraction from Database
📊 Configuration: Restaurant 8178, 100 orders max
🤖 Model: gpt-4o-2024-11-20
🔍 Found 45 orders to process

📦 Processing orders...
   ✅ Order #2950145: 13 items
   ✅ Order #2950234: 8 items
   ❌ Order #2950678: Download failed
   ...

✨ Summary:
   ✅ Successful: 42 orders
   ❌ Failed: 3 orders
   📦 Total Items: 387 items
   ⏱️  Duration: 8:34 minutes
```

## 🛠️ Enhancements Included

✅ **Progress Tracking**: Real-time status for each order  
✅ **Parallel Processing**: 4 orders at once (configurable)  
✅ **Detailed Logging**: See exactly what's happening  
✅ **Error Handling**: Skips failed orders, continues processing  
✅ **Transaction Safety**: All-or-nothing per order  
✅ **Duplicate Prevention**: Won't reprocess existing orders

## 📝 Database Schema

```sql
-- Orders are queried from
orders (id, restaurant_id, invoice_image, created_at)

-- Items are inserted into
benchmarking.invoice_items (
    id UUID,
    order_id BIGINT,
    item_name TEXT,
    qty NUMERIC,
    uom TEXT,
    unit_price NUMERIC,
    net_price NUMERIC,
    llm TEXT,  -- Model used (e.g., 'gpt-4o-2024-11-20')
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
```

## 🔧 Requirements

**Already installed**:

- ✅ psycopg2-binary (PostgreSQL adapter)
- ✅ All other dependencies from requirements.txt

**Need in .env**:

```env
LOCAL_DB_HOST=...
LOCAL_DB_PORT=5432
LOCAL_DB_NAME=...
LOCAL_DB_USER=...
LOCAL_DB_PASSWORD=...
OPENAI_API_KEY=sk-...
```

## 💡 Tips

**Faster Processing**: Increase `MAX_PARALLEL_ORDERS` to 8 or 10  
**Rate Limit Issues**: Decrease to 2 or 1  
**Process All**: Set `MAX_ORDERS_PER_RUN = 1000` or higher  
**Different Restaurant**: Change `RESTAURANT_ID`  
**Different Date**: Change `START_DATE`

## 📖 Full Documentation

See `helper/README_process_db_orders.md` for:

- Detailed features
- SQL queries used
- Error handling
- Monitoring queries
- Troubleshooting guide

