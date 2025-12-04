# ✅ .env File Configuration Guide

## Your .env file should look like this:

```bash
# OpenAI API Key (REQUIRED) - That's it!
OPENAI_API_KEY=sk-proj-your-actual-key-here
```

**Optional settings** (if you want to customize):

```bash
# Model (default: gpt-4-vision-preview)
OPENAI_MODEL=gpt-4-vision-preview

# API Settings
API_HOST=0.0.0.0
API_PORT=8000
```

## ⚠️ Important Notes

### 1. Variable Name Options

The system accepts BOTH formats (case-insensitive):

- `OPENAI_API_KEY=...` ✅ (recommended)
- `openai_api_key=...` ✅ (also works)

### 2. Your API Key Format

OpenAI API keys look like:

- **New format**: `sk-proj-xxxxxxxxxxxxxxxxxxxx` (starts with `sk-proj-`)
- **Old format**: `sk-xxxxxxxxxxxxxxxxxxxx` (starts with `sk-`)

### 3. Get Your API Key

If you don't have one:

1. Go to: https://platform.openai.com/api-keys
2. Click "Create new secret key"
3. Copy the key (you won't see it again!)
4. Paste it into your `.env` file

### 4. Check Your Credits

Make sure your OpenAI account has credits:

- Go to: https://platform.openai.com/usage
- Check your balance
- Add credits if needed

## 🧪 Test Your Configuration

Run this command to verify everything is set up correctly:

```bash
./setup.sh
```

Or manually:

```bash
# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Test configuration
python3 test_setup.py
```

## ✅ If Everything Works

You should see:

```
✅ .env file found
✅ OpenAI API key found
✅ OpenAI API working!
🎉 All checks passed!
```

## ❌ Common Issues

### "API key NOT found"

- Check spelling: `OPENAI_API_KEY=` (all caps)
- No spaces around `=`: `OPENAI_API_KEY=sk-...` ✅
- No quotes needed: `OPENAI_API_KEY=sk-proj-xxx` ✅

### "Invalid API key"

- Key must start with `sk-` or `sk-proj-`
- Copy the entire key (no spaces, no line breaks)
- Key is secret - never share it!

### "No credits/quota"

- Check: https://platform.openai.com/usage
- Add payment method if needed
- Check billing limits

## 📋 Complete Example

Your `/Users/issam/Desktop/elkaso/Backend/ai/benchmarking/.env` file:

```bash
OPENAI_API_KEY=sk-proj-Ab3dEfGh1JkLmN0pQrStUvWxYz1234567890AbCdEfGhIj
```

That's it! Just **1 line** is all you need! 🎉

## 🚀 Next Steps

After your `.env` is configured:

```bash
# Run setup and test
./setup.sh

# Start backend (Terminal 1)
source venv/bin/activate
python3 api.py

# Start frontend (Terminal 2)
cd invoice_web
flutter run -d chrome
```
