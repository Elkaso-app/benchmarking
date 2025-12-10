#!/bin/bash

# Deploy Kaso Invoice Analyzer to Benchmark Firebase Project
# This script will deploy to a separate Firebase project with benchmark domain

set -e

echo "🚀 Deploying to Benchmark Domain"
echo ""

# Check if project ID is provided
if [ -z "$1" ]; then
    echo "❌ Error: Firebase project ID required"
    echo ""
    echo "Usage: ./deploy_to_benchmark.sh <firebase-project-id>"
    echo ""
    echo "Steps to create a new Firebase project:"
    echo "1. Go to: https://console.firebase.google.com"
    echo "2. Click 'Add Project'"
    echo "3. Name it: 'kaso-benchmark' (or similar)"
    echo "4. Copy the Project ID"
    echo "5. Run: ./deploy_to_benchmark.sh <project-id>"
    exit 1
fi

PROJECT_ID=$1
BACKEND_URL="https://benchmarking-hp5l.onrender.com"

echo "📋 Project ID: $PROJECT_ID"
echo "🔗 Backend URL: $BACKEND_URL"
echo ""

# Set the Firebase project
echo "🔧 Setting Firebase project..."
firebase use $PROJECT_ID

# Build Flutter web app
echo "🏗️  Building Flutter web app..."
flutter build web --dart-define=API_URL=$BACKEND_URL --release

# Deploy to Firebase Hosting
echo "☁️  Deploying to Firebase Hosting..."
firebase deploy --only hosting --project $PROJECT_ID

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Your app should be available at:"
echo "   https://$PROJECT_ID.web.app"
echo "   or"
echo "   https://$PROJECT_ID.firebaseapp.com"
echo ""


