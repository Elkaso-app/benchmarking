#!/bin/bash

echo "🚀 Invoice Processing System - Setup Script"
echo "============================================"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found. Please install Python 3.8+"
    exit 1
fi

echo "✅ Python3 found: $(python3 --version)"
echo ""

# Create virtual environment if not exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
else
    echo "✅ Virtual environment already exists"
fi

echo ""
echo "🔌 Activating virtual environment..."
source venv/bin/activate

echo ""
echo "📥 Installing Python dependencies..."
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt

echo ""
echo "✅ Dependencies installed!"
echo ""

# Check .env file
if [ ! -f ".env" ]; then
    echo "⚠️  No .env file found!"
    echo ""
    echo "Please make sure your .env file has:"
    echo "  OPENAI_API_KEY=sk-proj-your-key-here"
    echo "  LLM_PROVIDER=openai"
    echo ""
    read -p "Press Enter after adding your OpenAI API key to .env..."
fi

echo "🧪 Testing configuration..."
python3 test_setup.py

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the system:"
echo "  1. Backend:  source venv/bin/activate && python3 api.py"
echo "  2. Frontend: cd invoice_web && flutter run -d chrome"



