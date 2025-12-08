# Invoice Processing Benchmarking Tool

A powerful benchmarking tool for extracting structured data from invoice PDFs using LLM Vision APIs (OpenAI GPT-4 Vision or Anthropic Claude).

## Features

- 🔍 **Direct LLM Processing**: Uses GPT-4 Vision or Claude Vision to process invoices directly
- 📊 **Structured Data Extraction**: Extracts invoice metadata, line items, and totals
- 📈 **CSV Export**: Exports all extracted data to CSV format for analysis
- 🚀 **REST API**: FastAPI-based API for integration with Flutter web frontend
- ⚡ **Batch Processing**: Process multiple invoices in parallel
- 📉 **Benchmarking**: Performance metrics and statistics

## Project Structure

```
benchmarking/
├── invoices/              # Input invoice PDFs (36 files)
├── output/                # Generated CSV and JSON files
├── api.py                 # FastAPI REST API
├── benchmark.py           # Benchmarking CLI tool
├── invoice_processor.py   # Core invoice processing logic
├── csv_exporter.py        # CSV export functionality
├── models.py              # Data models (Pydantic)
├── config.py              # Configuration management
├── requirements.txt       # Python dependencies
├── .env                   # Environment variables (create from .env.example)
└── README.md             # This file
```

## Installation

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure API Keys

Create a `.env` file from the example:

```bash
cp .env.example .env
```

Edit `.env` and add your API key:

```env
# For OpenAI (Recommended)
OPENAI_API_KEY=sk-your-api-key-here
LLM_PROVIDER=openai

# Or for Anthropic Claude
ANTHROPIC_API_KEY=sk-ant-your-api-key-here
LLM_PROVIDER=anthropic
```

## Usage

### Option 1: Command Line Interface

Run benchmark on all invoices in the `invoices/` directory:

```bash
python benchmark.py
```

Process only first 5 invoices:

```bash
python benchmark.py --limit 5
```

Use different provider:

```bash
python benchmark.py --provider anthropic
```

Custom invoices directory:

```bash
python benchmark.py --invoices-dir /path/to/invoices
```

### Option 2: REST API

Start the API server:

```bash
python api.py
```

Or with uvicorn:

```bash
uvicorn api:app --reload --host 0.0.0.0 --port 8000
```

API will be available at: http://localhost:8000

**API Documentation**: http://localhost:8000/docs

### API Endpoints

#### 1. Process Single Invoice

```bash
curl -X POST "http://localhost:8000/api/process" \
  -F "file=@invoices/FJ-1.pdf"
```

#### 2. Process Batch

```bash
curl -X POST "http://localhost:8000/api/process/batch" \
  -F "files=@invoices/FJ-1.pdf" \
  -F "files=@invoices/GD-1.pdf"
```

#### 3. Run Benchmark

```bash
curl -X POST "http://localhost:8000/api/benchmark?limit=5"
```

#### 4. List Invoices

```bash
curl "http://localhost:8000/api/invoices/list"
```

#### 5. Download CSV

```bash
curl "http://localhost:8000/api/download/items/invoice_items_20241203_120000.csv" \
  --output results.csv
```

## Output Files

The tool generates three types of output files in the `output/` directory:

### 1. Items CSV (`invoice_items_*.csv`)

Contains all extracted line items with:
- Filename, invoice metadata
- Item description, quantity, unit price, total
- Invoice totals and processing metrics

### 2. Summary CSV (`processing_summary_*.csv`)

Summary of processing results:
- Success/failure status
- Processing time per file
- Invoice totals
- Error messages (if any)

### 3. JSON Results (`benchmark_results_*.json`)

Complete benchmark data in JSON format for further analysis.

## Data Model

### InvoiceData Structure

```python
{
  "invoice_number": "INV-001",
  "invoice_date": "2024-01-15",
  "vendor_name": "ABC Company",
  "customer_name": "XYZ Corp",
  "currency": "USD",
  "items": [
    {
      "item_number": 1,
      "description": "Product A",
      "quantity": 10.0,
      "unit_price": 25.50,
      "total": 255.00,
      "unit": "pcs"
    }
  ],
  "subtotal": 255.00,
  "tax": 25.50,
  "total_amount": 280.50
}
```

## LLM Provider Comparison

### OpenAI GPT-4 Vision (Recommended)
- ✅ Excellent accuracy for invoice processing
- ✅ Fast processing (~2-5 seconds per invoice)
- ✅ Good at handling complex layouts
- 💰 Cost: ~$0.01-0.02 per invoice

### Anthropic Claude 3.5 Sonnet
- ✅ High accuracy and detail extraction
- ✅ Better at handling handwritten text
- ✅ More conservative with hallucinations
- 💰 Cost: ~$0.01-0.02 per invoice

## Configuration Options

Edit `config.py` or set environment variables:

| Setting | Default | Description |
|---------|---------|-------------|
| `LLM_PROVIDER` | `openai` | LLM provider: `openai` or `anthropic` |
| `OPENAI_MODEL` | `gpt-4-vision-preview` | OpenAI model to use |
| `ANTHROPIC_MODEL` | `claude-3-5-sonnet-20241022` | Anthropic model to use |
| `API_HOST` | `0.0.0.0` | API server host |
| `API_PORT` | `8000` | API server port |
| `INVOICES_DIR` | `invoices` | Input directory for invoices |
| `OUTPUT_DIR` | `output` | Output directory for results |

## Example Output

```
Found 36 PDF files to process
Using openai with model gpt-4-vision-preview
--------------------------------------------------------------------------------
Processing 1/36: FJ-1.pdf... ✓ Success - 12 items - 3.45s
Processing 2/36: GD-1.pdf... ✓ Success - 8 items - 2.87s
Processing 3/36: GD-2.pdf... ✓ Success - 15 items - 4.12s
...
--------------------------------------------------------------------------------
Benchmark Complete!
Total: 36 | Success: 35 | Failed: 1
Total Time: 128.45s | Average: 3.57s per file

Exporting results...
✓ Items CSV: output/invoice_items_20241203_143025.csv
✓ Summary CSV: output/processing_summary_20241203_143025.csv
✓ JSON Results: output/benchmark_results_20241203_143025.json
```

## Integration with Flutter Web

The REST API is ready for Flutter web integration. Example Flutter code:

```dart
// Process single invoice
var request = http.MultipartRequest(
  'POST',
  Uri.parse('http://localhost:8000/api/process'),
);
request.files.add(await http.MultipartFile.fromPath('file', pdfPath));
var response = await request.send();

// Run benchmark
var response = await http.post(
  Uri.parse('http://localhost:8000/api/benchmark?limit=10'),
);
```

## Troubleshooting

### "No API key found"
- Make sure you've created `.env` file with your API key
- Check that the key is valid and has sufficient credits

### "Failed to extract JSON"
- Some invoices may have complex layouts
- Try using a different provider (OpenAI vs Anthropic)
- Check the error details in the output JSON

### "PDF extraction failed"
- Ensure PDF is not password protected
- Check that PDF is not corrupted
- Try reducing max_pages in `pdf_to_images()`

## Performance Tips

1. **Batch Processing**: Process multiple invoices in parallel for better throughput
2. **Limit Pages**: Only process first page if items are on page 1
3. **Use OpenAI**: Generally faster than Anthropic for invoice processing
4. **Caching**: Consider caching results to avoid reprocessing

## Future Enhancements

- [ ] Support for image files (JPEG, PNG)
- [ ] Multi-page invoice handling
- [ ] Custom extraction templates
- [ ] Database storage option
- [ ] Real-time processing with WebSockets
- [ ] OCR fallback for better compatibility
- [ ] Invoice validation and error correction

## License

MIT License

## Support

For issues or questions, please open an issue on GitHub.


# benchmarking





