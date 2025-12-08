# Deployment Guide

This guide will help you deploy the Kaso Invoice Analyzer to production.

## Architecture

- **Backend**: Python FastAPI → Render.com (Free Tier)
- **Frontend**: Flutter Web → Firebase Hosting (Free Tier)

---

## 🔧 Backend Deployment (Render.com)

### Prerequisites
- Render.com account (sign up at https://render.com)
- OpenAI API key

### Step 1: Push Code to GitHub

```bash
# Make sure your code is in a GitHub repository
git add -A
git commit -m "Prepare for deployment"
git push origin main
```

### Step 2: Deploy on Render.com

1. **Go to Render Dashboard**: https://dashboard.render.com
2. **Click "New +" → "Web Service"**
3. **Connect your GitHub repository**
4. **Configure the service**:
   - **Name**: `kaso-invoice-backend`
   - **Region**: Choose closest to you
   - **Branch**: `main`
   - **Root Directory**: (leave empty or set to your backend folder)
   - **Environment**: `Docker`
   - **Plan**: `Free`

5. **Add Environment Variables**:
   - `OPENAI_API_KEY`: Your OpenAI API key
   - `DEMO`: `true` (or `false` for production)
   - `SLACK_WEBHOOK_URL`: Your Slack webhook URL (optional)

6. **Click "Create Web Service"**

7. **Wait for deployment** (5-10 minutes for first deploy)

8. **Your backend URL** will be: `https://kaso-invoice-backend.onrender.com`

### Health Check

Once deployed, visit: `https://your-app-name.onrender.com/health`

You should see:
```json
{
  "status": "healthy",
  "model": "gpt-4o",
  "timestamp": "2025-12-08T..."
}
```

---

## 🌐 Frontend Deployment (Firebase Hosting)

### Prerequisites
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project created at https://console.firebase.google.com

### Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add Project"
3. Name it (e.g., "kaso-invoice-analyzer")
4. Disable Google Analytics (optional)
5. Click "Create Project"

### Step 2: Initialize Firebase

```bash
cd invoice_web

# Login to Firebase
firebase login

# Initialize Firebase (if not done)
firebase init hosting
# Select your project
# Public directory: build/web
# Configure as single-page app: Yes
# Overwrite index.html: No
```

### Step 3: Update Firebase Project ID

Edit `invoice_web/.firebaserc`:
```json
{
  "projects": {
    "default": "your-actual-project-id"
  }
}
```

### Step 4: Build Flutter for Web

```bash
cd invoice_web

# Build with production API URL
flutter build web --dart-define=API_URL=https://your-backend-url.onrender.com
```

**Replace `your-backend-url.onrender.com` with your actual Render.com backend URL!**

### Step 5: Deploy to Firebase

```bash
firebase deploy --only hosting
```

### Your App is Live! 🎉

Firebase will provide your URL: `https://your-project-id.web.app`

---

## 🔄 Update Deployed Apps

### Update Backend

**Option 1: Auto-deploy (Recommended)**
- Render automatically redeploys when you push to GitHub main branch

**Option 2: Manual deploy**
1. Go to Render Dashboard
2. Click your service
3. Click "Manual Deploy" → "Deploy latest commit"

### Update Frontend

```bash
cd invoice_web

# Build with production API URL
flutter build web --dart-define=API_URL=https://your-backend-url.onrender.com

# Deploy
firebase deploy --only hosting
```

---

## 🌍 CORS Configuration

The backend is already configured to allow all origins for development. For production, you may want to restrict CORS to your Firebase domain.

Edit `api.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://your-project-id.web.app",
        "https://your-project-id.firebaseapp.com",
    ],
    # ... rest of config
)
```

---

## 💰 Free Tier Limits

### Render.com Free Tier
- ✅ 750 hours/month
- ✅ Automatic sleep after 15 min inactivity
- ✅ Cold start: ~30 seconds
- ❌ Spins down when inactive

### Firebase Hosting Free Tier
- ✅ 10 GB storage
- ✅ 360 MB/day transfer
- ✅ Custom domain support
- ✅ SSL certificate included

---

## 🔒 Environment Variables

### Backend (.env on Render)
```
OPENAI_API_KEY=sk-...
DEMO=true
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
```

### Frontend (Build-time)
```bash
flutter build web --dart-define=API_URL=https://your-backend.onrender.com
```

---

## 🐛 Troubleshooting

### Backend Issues

**Problem**: Service not responding
- **Solution**: Check Render logs in dashboard
- **Solution**: Verify environment variables are set

**Problem**: 500 Internal Server Error
- **Solution**: Check OpenAI API key is valid
- **Solution**: Check Render logs for Python errors

### Frontend Issues

**Problem**: Can't connect to backend
- **Solution**: Verify API_URL was set during build
- **Solution**: Check CORS settings in backend
- **Solution**: Ensure backend is deployed and running

**Problem**: Firebase deploy fails
- **Solution**: Run `flutter build web` first
- **Solution**: Check `.firebaserc` has correct project ID
- **Solution**: Run `firebase login` again

---

## 📊 Monitoring

### Backend Health Check
```bash
curl https://your-backend.onrender.com/health
```

### View Render Logs
1. Go to Render Dashboard
2. Click your service
3. Click "Logs" tab

### Firebase Analytics
1. Go to Firebase Console
2. Click your project
3. View Hosting metrics

---

## 🚀 Production Checklist

- [ ] Backend deployed on Render
- [ ] Environment variables set on Render
- [ ] Frontend built with correct API_URL
- [ ] Frontend deployed to Firebase
- [ ] Health check endpoint works
- [ ] Upload invoice test works
- [ ] CORS configured properly
- [ ] SSL certificate active (automatic)

---

## 📝 Notes

- **Render Free Tier** spins down after 15 minutes of inactivity
- First request after sleep will take ~30 seconds (cold start)
- Consider **paid tier** ($7/month) for production to avoid cold starts
- **Firebase Hosting** is always fast (no cold starts)

---

## 🔗 Useful Links

- **Render Dashboard**: https://dashboard.render.com
- **Firebase Console**: https://console.firebase.google.com
- **Render Docs**: https://render.com/docs
- **Firebase Hosting Docs**: https://firebase.google.com/docs/hosting

---

## 🎉 You're Done!

Your Kaso Invoice Analyzer is now live and accessible worldwide!

**Frontend**: `https://your-project-id.web.app`  
**Backend**: `https://your-backend.onrender.com`

