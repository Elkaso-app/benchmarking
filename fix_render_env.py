#!/usr/bin/env python3
"""
Update Render environment variables
"""
import requests
import sys

RENDER_API_KEY = "rnd_uaiScJB8ROXkZSw1xAuuHi0nArIs"
RENDER_API_BASE = "https://api.render.com/v1"

headers = {
    "Authorization": f"Bearer {RENDER_API_KEY}",
    "Content-Type": "application/json"
}

def get_services():
    """Get all services"""
    response = requests.get(f"{RENDER_API_BASE}/services", headers=headers)
    if response.status_code == 200:
        return response.json()
    return None

def update_env_vars(service_id, openai_key):
    """Update environment variables"""
    env_vars = [
        {
            "key": "OPENAI_API_KEY",
            "value": openai_key
        },
        {
            "key": "DEMO",
            "value": "true"
        }
    ]
    
    response = requests.put(
        f"{RENDER_API_BASE}/services/{service_id}/env-vars",
        headers=headers,
        json=env_vars
    )
    
    return response

def main():
    if len(sys.argv) < 2:
        print("❌ Usage: python fix_render_env.py <OPENAI_API_KEY>")
        sys.exit(1)
    
    openai_key = sys.argv[1]
    
    print("🔍 Finding your service...")
    services = get_services()
    
    if not services:
        print("❌ Could not retrieve services")
        sys.exit(1)
    
    # Find the benchmarking service
    target_service = None
    for service in services:
        if "benchmark" in service["service"]["name"].lower():
            target_service = service["service"]
            break
    
    if not target_service:
        print("❌ Could not find benchmarking service")
        print("Available services:")
        for service in services:
            print(f"  - {service['service']['name']}")
        sys.exit(1)
    
    service_id = target_service["id"]
    service_name = target_service["name"]
    
    print(f"✅ Found service: {service_name}")
    print(f"📝 Service ID: {service_id}")
    print("\n🔧 Updating environment variables...")
    
    response = update_env_vars(service_id, openai_key)
    
    if response.status_code in [200, 201]:
        print("\n✅ Environment variables updated!")
        print("\n⏳ Service will redeploy automatically (2-3 minutes)")
        print(f"\n📊 Monitor progress:")
        print(f"   https://dashboard.render.com/web/{service_id}")
    else:
        print(f"\n❌ Failed to update environment variables")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")

if __name__ == "__main__":
    main()

