# Quick Deployment Guide

Get your app live in 15 minutes! 🚀

## 📋 Prerequisites

1. ✅ GitHub account (https://github.com)
2. ✅ Render account (https://render.com)
3. ✅ Firebase account (https://firebase.google.com)
4. ✅ OpenAI API key (https://platform.openai.com)

---

## 🔧 Backend Deployment (5 minutes)

### 1. Push to GitHub

```bash
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking
git add -A
git commit -m "Ready for deployment"
git push origin main
```

### 2. Deploy on Render.com

1. Go to https://dashboard.render.com
2. Click **"New +" → "Web Service"**
3. Connect your GitHub repository
4. Settings:
   - Name: `kaso-invoice-backend`
   - Environment: **Docker**
   - Plan: **Free**
5. Add environment variables:
   - `OPENAI_API_KEY`: `sk-...` (your key)
   - `DEMO`: `true`
6. Click **"Create Web Service"**
7. Wait 5-10 minutes ⏱️

**Your backend URL**: `https://kaso-invoice-backend.onrender.com`

---

## 🌐 Frontend Deployment (10 minutes)

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **"Add Project"**
3. Name it: `kaso-invoice-analyzer`
4. Create project

### 3. Deploy Frontend

```bash
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking/invoice_web

# Login to Firebase
firebase login

# Initialize (one-time setup)
firebase init hosting
# ✅ Select your project
# ✅ Public directory: build/web
# ✅ Single-page app: Yes

# Update .firebaserc with your project ID
# Edit .firebaserc and replace "your-project-id" with actual ID

# Deploy with your backend URL
./deploy.sh https://kaso-invoice-backend.onrender.com
```

---

## ✅ Done!

**Frontend**: `https://your-project-id.web.app`  
**Backend**: `https://kaso-invoice-backend.onrender.com`

---

## 🔄 Update Deployed Apps

### Update Backend
```bash
git add -A
git commit -m "Update"
git push origin main
# Render auto-deploys!
```

### Update Frontend
```bash
cd invoice_web
./deploy.sh https://kaso-invoice-backend.onrender.com
```

---

## 🐛 Troubleshooting

### Backend not responding?
- Wait 30 seconds (cold start)
- Check Render logs in dashboard

### Frontend can't connect?
- Rebuild with correct API URL
- Check CORS in `api.py`

---

## 📞 Need Help?

See full documentation: `DEPLOYMENT.md`

