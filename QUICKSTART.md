# 🚀 Quick Start Guide

Get started with the Invoice Processing Benchmarking Tool in 3 minutes!

## Step 1: Install Dependencies

```bash
pip install -r requirements.txt
```

## Step 2: Configure API Key

Create `.env` file:

```bash
# For OpenAI (Recommended)
OPENAI_API_KEY=sk-your-api-key-here
LLM_PROVIDER=openai
```

Get your API key:
- **OpenAI**: https://platform.openai.com/api-keys
- **Anthropic**: https://console.anthropic.com/

## Step 3: Run!

### Quick Test (5 invoices)

```bash
python benchmark.py --limit 5
```

### Full Benchmark (all 36 invoices)

```bash
python benchmark.py
```

### Start API Server

```bash
python api.py
```

Then open: http://localhost:8000/docs

## What You'll Get

✅ **CSV Files** with all extracted invoice data  
✅ **JSON Results** with complete processing details  
✅ **Performance Metrics** (success rate, processing time)  

Output files are saved in `output/` directory.

## Example Output

```
Found 36 PDF files to process
Using openai with model gpt-4-vision-preview
--------------------------------------------------------------------------------
Processing 1/36: FJ-1.pdf... ✓ Success - 12 items - 3.45s
Processing 2/36: GD-1.pdf... ✓ Success - 8 items - 2.87s
...
--------------------------------------------------------------------------------
Benchmark Complete!
Total: 36 | Success: 35 | Failed: 1

✓ Items CSV: output/invoice_items_20241203_143025.csv
✓ Summary CSV: output/processing_summary_20241203_143025.csv
```

## API Usage

### Process Single Invoice

```bash
curl -X POST "http://localhost:8000/api/process" \
  -F "file=@invoices/FJ-1.pdf"
```

### Run Benchmark via API

```bash
curl -X POST "http://localhost:8000/api/benchmark?limit=5"
```

## Troubleshooting

**"No API key found"**  
→ Make sure `.env` file exists with your API key

**"Module not found"**  
→ Run `pip install -r requirements.txt`

**Processing fails**  
→ Try different provider: `--provider anthropic`

## Next Steps

- Read full [README.md](README.md) for detailed documentation
- Integrate with Flutter web frontend using the REST API
- Customize extraction prompts in `invoice_processor.py`

Happy benchmarking! 🎉



