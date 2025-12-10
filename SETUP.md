# Invoice Processing System - Setup Guide

## Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
cd invoice_web && flutter pub get
```

### 2. Configure API Key

Create `.env` file:
```bash
OPENAI_API_KEY=your-openai-api-key-here
```

Get your API key: https://platform.openai.com/api-keys

### 3. Run

**Backend (Terminal 1):**
```bash
python3 api.py
```

**Frontend (Terminal 2):**
```bash
cd invoice_web
flutter run -d chrome --web-port 3000
```

**Open**: http://localhost:3000

## Features

- Upload PDF invoices
- AI extraction with GPT-4o
- Smart summary table with price ranges
- CSV export
- Item aggregation by name

## API

Backend: http://localhost:8001
Documentation: http://localhost:8001/docs






