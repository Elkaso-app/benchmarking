# 🚀 Quick Setup Guide - Complete Invoice Processing System

## Overview

This is a complete invoice processing benchmarking system with:
- **Backend**: Python FastAPI server with OpenAI/Anthropic LLM integration
- **Frontend**: Flutter web application with modern UI

## 📋 Prerequisites

1. **Python 3.8+** - For backend
2. **Flutter 3.10+** - For frontend
3. **OpenAI API Key** or **Anthropic API Key**

## 🎯 Quick Start (2 Steps)

### Step 1: Start Backend Server

```bash
# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env

# Edit .env and add your API key:
# OPENAI_API_KEY=sk-your-key-here
# LLM_PROVIDER=openai

# Start server
python api.py
```

Server will run at: **http://localhost:8000**

### Step 2: Start Flutter Web App

```bash
# Navigate to Flutter project
cd invoice_web

# Install dependencies
flutter pub get

# Run app
flutter run -d chrome
```

App will open at: **http://localhost:8080**

## 🎨 Using the Application

### Option 1: Upload Your Own Invoices

1. Click **"Upload Invoices"** tab
2. Select PDF files from your computer
3. Click **"Process Invoices"**
4. View results and download CSV

### Option 2: Benchmark Server Invoices

1. Click **"Run Benchmark"** tab
2. Choose how many invoices to process
3. Click **"Run Benchmark"**
4. Download CSV/JSON reports

## 📁 Project Structure

```
benchmarking/
├── Backend (Python + FastAPI)
│   ├── api.py                 # REST API server
│   ├── benchmark.py           # CLI tool
│   ├── invoice_processor.py   # LLM processing
│   ├── requirements.txt       # Python dependencies
│   └── invoices/              # 36 sample PDF invoices
│
└── invoice_web/ (Flutter Web)
    ├── lib/
    │   ├── pages/             # UI pages
    │   ├── services/          # API client
    │   └── widgets/           # Reusable components
    └── pubspec.yaml           # Flutter dependencies
```

## 🔧 Configuration

### Backend Configuration (`.env`)

```env
# OpenAI API Key (only this is required!)
OPENAI_API_KEY=sk-your-key-here
```

### Frontend Configuration

Edit `invoice_web/lib/config.dart` if backend is on different port:

```dart
static const String apiBaseUrl = 'http://localhost:8000';
```

## 📊 What You'll Get

### CSV Exports

1. **Items CSV** - All extracted line items
   - Filename, invoice metadata
   - Item descriptions, quantities, prices
   - Processing metrics

2. **Summary CSV** - Processing overview
   - Success/failure status
   - Processing times
   - Invoice totals

### JSON Export

Complete benchmark data with all details for further analysis.

## ⚡ Command Line Usage (Optional)

You can also use the backend without the frontend:

```bash
# Test with 5 invoices
python benchmark.py --limit 5

# Process all invoices
python benchmark.py

# Use Anthropic instead of OpenAI
python benchmark.py --provider anthropic
```

Results are saved in `output/` directory.

## 🌐 API Documentation

When backend is running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

## 🎯 Testing the System

### Quick Test Flow

1. Start backend: `python api.py`
2. Start frontend: `cd invoice_web && flutter run -d chrome`
3. Click "Run Benchmark" tab
4. Select "First 5 invoices (test)"
5. Click "Run Benchmark"
6. Wait ~15-25 seconds
7. View results and download CSV

### Expected Results

- **Processing time**: 2-5 seconds per invoice
- **Success rate**: > 90% (depends on invoice quality)
- **Total time for 5 invoices**: ~15-25 seconds
- **Output**: 2 CSV files + 1 JSON file

## 🐛 Troubleshooting

### Backend Issues

**"No API key found"**
```bash
# Make sure .env file exists and has your API key
cat .env
```

**"Port 8000 already in use"**
```bash
# Kill existing process or change port in .env
lsof -ti:8000 | xargs kill
```

### Frontend Issues

**"Backend Server Not Running"**
- Make sure `python api.py` is running
- Check http://localhost:8000/health in browser
- Click refresh icon in app

**"CORS Error"**
- Backend already has CORS enabled
- Make sure backend is running on http://localhost:8000

**"Flutter not found"**
```bash
# Install Flutter from https://flutter.dev
flutter --version
```

### Processing Issues

**"Processing failed"**
- Check your API key has credits
- Check API key is valid
- Try different provider (OpenAI vs Anthropic)

**"Slow processing"**
- Normal: LLM processing takes 2-5s per invoice
- Check your internet connection
- Check API rate limits

## 💰 Cost Estimate

- **OpenAI GPT-4 Vision**: ~$0.01-0.02 per invoice
- **Anthropic Claude**: ~$0.01-0.02 per invoice
- **36 invoices**: ~$0.36-0.72 total

## 🚀 Production Deployment

### Backend

Deploy Python API to:
- Heroku
- DigitalOcean
- AWS EC2
- Google Cloud Run

### Frontend

Build and deploy Flutter web:

```bash
cd invoice_web
flutter build web --release
```

Deploy `build/web/` to:
- Firebase Hosting
- Netlify
- Vercel
- AWS S3

## 📚 Additional Resources

- **Backend README**: `/README.md` - Complete backend documentation
- **Frontend README**: `/invoice_web/README.md` - Flutter app details
- **Quick Start**: `/QUICKSTART.md` - Backend CLI guide
- **API Docs**: http://localhost:8000/docs (when running)

## 🎉 Next Steps

1. **Test with sample invoices**: Use the benchmark feature
2. **Upload your own invoices**: Test with your PDF invoices
3. **Customize extraction**: Edit prompts in `invoice_processor.py`
4. **Integrate with your system**: Use the REST API
5. **Deploy to production**: Follow deployment guide above

## 💡 Tips

- Start with "First 5 invoices" to test quickly
- Check CSV exports to verify extracted data
- Use JSON export for programmatic access
- Monitor backend logs for debugging
- Use Chrome DevTools to debug frontend

## 🆘 Need Help?

1. Check backend logs in terminal
2. Check browser console (F12)
3. Visit API docs: http://localhost:8000/docs
4. Review README files for each component

---

**Ready to go!** Start both servers and process your first invoices! 🎊

