"""Test OpenAI API key directly"""
import os
from openai import OpenAI

# Read from .env file
from dotenv import load_dotenv
load_dotenv(override=True)  # Force reload

api_key = os.getenv("OPENAI_API_KEY")

print("=" * 60)
print("🔍 Testing OpenAI API Key")
print("=" * 60)

if not api_key:
    print("❌ No API key found in .env file")
    print("\n💡 Make sure your .env file contains:")
    print("   OPENAI_API_KEY=sk-proj-your-key-here")
    exit(1)

print(f"✅ API key found: {api_key[:15]}...")
print(f"   Full prefix: {api_key[:20]}...")

# Test the key
print("\n🧪 Testing API connection with simple request...")

try:
    client = OpenAI(api_key=api_key)
    
    # Simple test with gpt-3.5-turbo (cheaper)
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": "Say 'API key works!' in exactly 3 words"}
        ],
        max_tokens=10
    )
    
    result = response.choices[0].message.content
    print(f"✅ API Key Works! Response: '{result}'")
    print("\n" + "=" * 60)
    print("🎉 SUCCESS! Your OpenAI API key is working!")
    print("=" * 60)
    print("\n💰 Cost of this test: ~$0.0001 (basically free)")
    print("\n✅ You can now process invoices!")
    print("   Go to: http://localhost:8080")
    print("   Click 'Run Benchmark' and try 5 invoices")
    
except Exception as e:
    print(f"❌ API Error: {e}")
    print("\n💡 Common issues:")
    print("   1. Insufficient quota - add credits at:")
    print("      https://platform.openai.com/account/billing")
    print("   2. Invalid API key - check it's correct")
    print("   3. Key not activated yet - wait 2-5 minutes")
    print("\n📊 Check your usage:")
    print("   https://platform.openai.com/usage")
    exit(1)


