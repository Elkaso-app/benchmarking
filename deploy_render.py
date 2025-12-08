#!/usr/bin/env python3
"""
Deploy Kaso Invoice Backend to Render.com using API
"""
import requests
import json
import sys
import time

# Render API Configuration
RENDER_API_KEY = "rnd_uaiScJB8ROXkZSw1xAuuHi0nArIs"
RENDER_API_BASE = "https://api.render.com/v1"

headers = {
    "Authorization": f"Bearer {RENDER_API_KEY}",
    "Content-Type": "application/json"
}

def get_owners():
    """Get owner (user/team) ID"""
    response = requests.get(f"{RENDER_API_BASE}/owners", headers=headers)
    if response.status_code == 200:
        owners = response.json()
        if owners:
            return owners[0]["owner"]["id"]
    return None

def create_web_service(owner_id, openai_key, slack_webhook=""):
    """Create a new web service on Render"""
    
    service_data = {
        "type": "web_service",
        "name": "kaso-invoice-backend",
        "ownerId": owner_id,
        "repo": "https://github.com/Elkaso-app/benchmarking",
        "branch": "main",
        "envSpecificDetails": {
            "docker": {
                "dockerfilePath": "./Dockerfile"
            }
        },
        "serviceDetails": {
            "env": "docker",
            "region": "frankfurt",
            "plan": "free",
            "healthCheckPath": "/health",
            "envVars": [
                {
                    "key": "OPENAI_API_KEY",
                    "value": openai_key
                },
                {
                    "key": "DEMO",
                    "value": "true"
                }
            ]
        }
    }
    
    # Add Slack webhook if provided
    if slack_webhook:
        service_data["serviceDetails"]["envVars"].append({
            "key": "SLACK_WEBHOOK_URL",
            "value": slack_webhook
        })
    
    response = requests.post(
        f"{RENDER_API_BASE}/services",
        headers=headers,
        json=service_data
    )
    
    return response

def list_services():
    """List all services"""
    response = requests.get(f"{RENDER_API_BASE}/services", headers=headers)
    if response.status_code == 200:
        return response.json()
    return None

def main():
    print("🚀 Kaso Invoice Backend - Render Deployment\n")
    
    # Check if OpenAI key is provided
    if len(sys.argv) < 2:
        print("❌ Error: OpenAI API key required")
        print("Usage: python deploy_render.py <OPENAI_API_KEY> [SLACK_WEBHOOK_URL]")
        print("\nExample:")
        print("  python deploy_render.py sk-proj-xxx")
        print("  python deploy_render.py sk-proj-xxx https://hooks.slack.com/...")
        sys.exit(1)
    
    openai_key = sys.argv[1]
    slack_webhook = sys.argv[2] if len(sys.argv) > 2 else ""
    
    print("✅ API Key configured")
    
    # Get owner ID
    print("📋 Getting account information...")
    owner_id = get_owners()
    
    if not owner_id:
        print("❌ Failed to get owner ID. Please check your Render API key.")
        sys.exit(1)
    
    print(f"✅ Owner ID: {owner_id}")
    
    # Check existing services
    print("\n🔍 Checking existing services...")
    services = list_services()
    
    existing_service = None
    if services:
        for service in services:
            if service["service"]["name"] == "kaso-invoice-backend":
                existing_service = service["service"]
                break
    
    if existing_service:
        print(f"⚠️  Service 'kaso-invoice-backend' already exists")
        print(f"   URL: {existing_service.get('serviceDetails', {}).get('url', 'N/A')}")
        print(f"   Status: {existing_service.get('serviceDetails', {}).get('status', 'N/A')}")
        print("\nℹ️  To redeploy, trigger a manual deploy in Render dashboard:")
        print(f"   https://dashboard.render.com/web/{existing_service['id']}")
        return
    
    # Create new service
    print("\n🚀 Creating new web service...")
    response = create_web_service(owner_id, openai_key, slack_webhook)
    
    if response.status_code in [200, 201]:
        service = response.json()
        service_url = service.get("service", {}).get("serviceDetails", {}).get("url", "")
        service_id = service.get("service", {}).get("id", "")
        
        print("\n✅ Service created successfully!")
        print(f"\n📝 Service Details:")
        print(f"   Name: kaso-invoice-backend")
        print(f"   ID: {service_id}")
        print(f"   URL: {service_url or 'Will be assigned during deployment'}")
        print(f"   Region: Frankfurt")
        print(f"   Plan: Free")
        
        print(f"\n⏳ Deployment in progress...")
        print(f"   This will take 5-10 minutes for first deployment")
        print(f"\n📊 Monitor progress:")
        print(f"   https://dashboard.render.com/web/{service_id}")
        
        print(f"\n🔗 Once deployed, your API will be at:")
        print(f"   https://kaso-invoice-backend.onrender.com")
        print(f"   Health check: https://kaso-invoice-backend.onrender.com/health")
        
        print("\n💡 Next steps:")
        print("   1. Wait for deployment to complete (check dashboard)")
        print("   2. Test health endpoint")
        print("   3. Deploy frontend with this backend URL")
        
    else:
        print(f"\n❌ Failed to create service")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
        sys.exit(1)

if __name__ == "__main__":
    main()

