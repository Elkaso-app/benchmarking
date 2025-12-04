# 🚀 How to Run - Simple 3-Step Guide

## Step 1️⃣: Verify Your .env File

Your `.env` file at `/Users/issam/Desktop/elkaso/Backend/ai/benchmarking/.env` should contain:

```bash
OPENAI_API_KEY=sk-proj-your-actual-key-here
```

✅ **You said you already added the key**, so you're ready! (Just 1 line needed!)

## Step 2️⃣: Setup & Install Dependencies

Run the setup script:

```bash
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking
./setup.sh
```

This will:
- Create a virtual environment
- Install all Python dependencies
- Test your OpenAI connection

**Or manually:**

```bash
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking

# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Test setup
python3 test_setup.py
```

## Step 3️⃣: Start Both Servers

### Terminal 1 - Backend Server

```bash
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking
source venv/bin/activate
python3 api.py
```

✅ Backend will run at: **http://localhost:8000**

### Terminal 2 - Flutter Web Frontend

```bash
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking/invoice_web
flutter run -d chrome
```

✅ Frontend will open at: **http://localhost:8080**

## 🎯 Quick Test (5 invoices)

Once both servers are running:

1. Open browser to http://localhost:8080
2. Click **"Run Benchmark"** tab (bottom navigation)
3. Select **"First 5 invoices (test)"** from dropdown
4. Click **"Run Benchmark"** button
5. Wait ~20-30 seconds
6. View results and click **"Download"** buttons!

## 📊 Expected Output

For 5 invoices:
- ⏱️ Processing time: ~20-30 seconds total
- ✅ Success rate: 90%+ (depends on invoice quality)
- 💾 Downloads: 2 CSV files + 1 JSON file

## 🆘 Troubleshooting

### Backend won't start
```bash
# Make sure you're in virtual environment
source venv/bin/activate

# Try running test first
python3 test_setup.py
```

### Frontend shows "Backend Offline"
- Check if backend is running: http://localhost:8000/health
- Make sure it's on port 8000
- Click the refresh icon in the app

### "Invalid API Key" error
- Check your `.env` file has correct format
- Key should start with `sk-` or `sk-proj-`
- No quotes, no spaces around `=`

### Flutter not found
```bash
# Install Flutter
# Visit: https://docs.flutter.dev/get-started/install

# Or check if installed
flutter doctor
```

## 📝 Command Summary

**One-time setup:**
```bash
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking
./setup.sh
```

**Every time you run:**

Terminal 1:
```bash
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking
source venv/bin/activate
python3 api.py
```

Terminal 2:
```bash
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking/invoice_web
flutter run -d chrome
```

## 🎉 That's It!

You now have a fully working invoice processing system!

**Ready to start?** Run `./setup.sh` first! 🚀

