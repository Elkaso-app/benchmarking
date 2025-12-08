#!/bin/bash

# Kaso Invoice Analyzer - Firebase Deployment Script
# Usage: ./deploy.sh <backend-url>
# Example: ./deploy.sh https://kaso-invoice-backend.onrender.com

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if API_URL is provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}⚠️  No backend URL provided${NC}"
    echo "Usage: ./deploy.sh <backend-url>"
    echo "Example: ./deploy.sh https://kaso-invoice-backend.onrender.com"
    exit 1
fi

API_URL=$1

echo -e "${BLUE}🚀 Starting deployment...${NC}"
echo -e "${BLUE}Backend URL: ${API_URL}${NC}"
echo ""

# Step 1: Clean previous build
echo -e "${BLUE}🧹 Cleaning previous build...${NC}"
flutter clean

# Step 2: Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

# Step 3: Build for web with API URL
echo -e "${BLUE}🏗️  Building Flutter web app...${NC}"
flutter build web --dart-define=API_URL=$API_URL --release

# Step 4: Deploy to Firebase
echo -e "${BLUE}☁️  Deploying to Firebase Hosting...${NC}"
firebase deploy --only hosting

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo -e "${GREEN}Your app is now live on Firebase Hosting${NC}"
echo ""
echo -e "Run ${BLUE}firebase hosting:channel:list${NC} to see your deployed URL"

