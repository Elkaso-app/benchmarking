"""Quick test script to verify OpenAI setup."""
import os
from pathlib import Path

print("=" * 60)
print("🔍 Testing OpenAI Configuration")
print("=" * 60)

# Check .env file exists
env_file = Path(".env")
if env_file.exists():
    print("✅ .env file found")
else:
    print("❌ .env file NOT found")
    print("\nPlease create .env file with:")
    print("OPENAI_API_KEY=your-key-here")
    print("LLM_PROVIDER=openai")
    exit(1)

# Try to load environment
try:
    from dotenv import load_dotenv
    load_dotenv()
    print("✅ dotenv loaded")
except ImportError:
    print("⚠️  python-dotenv not installed (optional)")

# Check OpenAI API key
api_key = os.getenv("OPENAI_API_KEY") or os.getenv("openai_api_key")
if api_key:
    print(f"✅ OpenAI API key found (starts with: {api_key[:10]}...)")
else:
    print("❌ OpenAI API key NOT found in environment")
    print("\n💡 Make sure your .env file has:")
    print("   OPENAI_API_KEY=sk-proj-...")
    print("   (or openai_api_key=sk-proj-...)")
    exit(1)

# Test OpenAI connection
print("\n🧪 Testing OpenAI API connection...")
try:
    from openai import OpenAI
    client = OpenAI(api_key=api_key)
    
    # Simple test call
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",  # Cheaper model for testing
        messages=[{"role": "user", "content": "Say 'OK' if you can read this"}],
        max_tokens=10
    )
    
    result = response.choices[0].message.content
    print(f"✅ OpenAI API working! Response: {result}")
    print("\n" + "=" * 60)
    print("🎉 All checks passed! Your setup is ready.")
    print("=" * 60)
    print("\nNext steps:")
    print("1. Start backend: python3 api.py")
    print("2. Start frontend: cd invoice_web && flutter run -d chrome")
    
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    print("\n💡 Install dependencies:")
    print("   python3 -m venv venv")
    print("   source venv/bin/activate")
    print("   pip install -r requirements.txt")
    
except Exception as e:
    print(f"❌ OpenAI API Error: {e}")
    print("\n💡 Possible issues:")
    print("   - Invalid API key")
    print("   - No credits/quota available")
    print("   - Network connection issue")
    exit(1)



