#!/bin/bash

# Invoice Processing Benchmarking Tool - Quick Start Script

echo "🚀 Invoice Processing Benchmarking Tool"
echo "========================================"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  No .env file found!"
    echo "📝 Creating .env from .env.example..."
    cp .env.example .env
    echo "✅ .env file created!"
    echo ""
    echo "⚠️  IMPORTANT: Please edit .env and add your API key:"
    echo "   - For OpenAI: Add OPENAI_API_KEY"
    echo "   - For Anthropic: Add ANTHROPIC_API_KEY"
    echo ""
    read -p "Press Enter after adding your API key..."
fi

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created!"
fi

# Activate venv
echo "🔌 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements.txt --quiet

echo ""
echo "✅ Setup complete!"
echo ""
echo "Available commands:"
echo "  1) Run benchmark on all invoices"
echo "  2) Run benchmark on first 5 invoices (test)"
echo "  3) Start API server"
echo "  4) Exit"
echo ""

read -p "Choose option (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🔍 Running benchmark on ALL invoices..."
        python benchmark.py
        ;;
    2)
        echo ""
        echo "🔍 Running benchmark on first 5 invoices..."
        python benchmark.py --limit 5
        ;;
    3)
        echo ""
        echo "🌐 Starting API server..."
        echo "📡 API will be available at: http://localhost:8000"
        echo "📚 Documentation at: http://localhost:8000/docs"
        python api.py
        ;;
    4)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac



