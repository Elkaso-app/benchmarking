# 🎯 START HERE - Invoice Processing System

Welcome! This is a complete invoice processing benchmarking tool with AI extraction.

## ⚡ Quick Start (Copy & Paste)

### 1️⃣ Start Backend (Terminal 1)

```bash
# Install Python dependencies
pip install -r requirements.txt

# Create config file (just 1 line!)
echo 'OPENAI_API_KEY=your-key-here' > .env

# Start server
python api.py
```

### 2️⃣ Start Frontend (Terminal 2)

```bash
# Navigate to Flutter app
cd invoice_web

# Install Flutter dependencies
flutter pub get

# Run web app
flutter run -d chrome
```

## 🎨 What It Does

✅ Extracts structured data from invoice PDFs using AI  
✅ Processes invoices in batch or individually  
✅ Exports results to CSV for analysis  
✅ Provides beautiful web interface  
✅ Shows detailed benchmarking metrics  

## 📖 Documentation

- **[FLUTTER_SETUP.md](FLUTTER_SETUP.md)** - Complete setup guide for both backend & frontend
- **[README.md](README.md)** - Backend API documentation
- **[invoice_web/README.md](invoice_web/README.md)** - Flutter app documentation
- **[QUICKSTART.md](QUICKSTART.md)** - Backend CLI usage

## 🔑 Get Your API Key

**OpenAI (Recommended)**: https://platform.openai.com/api-keys

Then edit `.env` file:
```
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
```

## 🎯 First Test

1. Start both backend and frontend (commands above)
2. Open browser to http://localhost:8080
3. Click "Run Benchmark" tab
4. Select "First 5 invoices (test)"
5. Click "Run Benchmark"
6. Wait ~20 seconds
7. Download CSV results! 🎉

## 📊 Sample Data

The `invoices/` folder contains **36 sample PDF invoices** ready to test!

## 🆘 Need Help?

Backend not connecting?
```bash
# Check if backend is running
curl http://localhost:8000/health
```

Flutter issues?
```bash
# Make sure Flutter is installed
flutter doctor
```

## 🌟 Features

- **Direct LLM Processing**: GPT-4 Vision reads invoices directly
- **No OCR Needed**: AI understands invoice structure
- **CSV Export**: Get all data in spreadsheet format
- **REST API**: Easy integration with other systems
- **Modern UI**: Beautiful Flutter web interface
- **Real-time Status**: See processing progress live

---

**Ready?** Follow the Quick Start commands above! 🚀

