# Deploy to Render.com — Complete Guide

This bot requires **two services** on Render:
1. **Web Service** — Flask API + Admin Dashboard
2. **Background Worker** — Telegram Bot (polling)

---

## Step 1: Prepare GitHub Repository

```bash
# Initialize git
git init
git add .
git commit -m "Initial commit: Swiggy bot upgraded with dashboard"
git branch -M main

# Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/swiggy-bot.git
git push -u origin main
```

---

## Step 2: Create Render Account

1. Go to [Render.com](https://render.com)
2. Sign up (GitHub OAuth recommended)
3. Go to [Dashboard](https://dashboard.render.com)

---

## Step 3: Deploy Web Service

1. Click **"New +"** → **"Web Service"**

2. **Connect GitHub:**
   - Select "Public GitHub repository"
   - Search for your repo name
   - Click "Connect"

3. **Configure Service:**
   - **Name:** `swiggy-bot-web` (or your choice)
   - **Region:** Choose closest to you (e.g., Singapore for India)
   - **Branch:** `main`
   - **Runtime:** `Python 3`
   - **Build Command:** 
     ```
     pip install -r requirements.txt
     ```
   - **Start Command:**
     ```
     gunicorn --bind 0.0.0.0:$PORT --worker-class gevent bot_upgraded:app
     ```

4. **Environment Variables:**
   Click "Add Environment Variable" and add:
   ```
   BOT_TOKEN = your_bot_token_here
   ADMIN_PASSWORD = your_secure_password
   FLASK_SECRET = generate_with: python -c "import secrets; print(secrets.token_hex(32))"
   PORT = 5000
   SESSION_TTL_SECONDS = 86400
   MAX_CONCURRENT_UPDATES = 32
   ```

5. **Plan Selection:**
   - Select appropriate tier (Free tier has limitations)
   - Check pricing

6. **Click "Deploy Web Service"**

**Wait for deployment (5-10 minutes)** ✅

Your web service URL: `https://swiggy-bot-web.onrender.com`

---

## Step 4: Deploy Background Worker

1. Click **"New +"** → **"Background Worker"**

2. **Connect GitHub:**
   - Select the same repository
   - "Connect"

3. **Configure Worker:**
   - **Name:** `swiggy-bot-worker`
   - **Region:** Same as web service
   - **Branch:** `main`
   - **Runtime:** `Python 3`
   - **Build Command:**
     ```
     pip install -r requirements.txt
     ```
   - **Start Command:**
     ```
     python bot_upgraded.py
     ```

4. **Environment Variables:**
   Add the same variables as the web service:
   ```
   BOT_TOKEN = your_bot_token_here
   ADMIN_PASSWORD = your_secure_password
   FLASK_SECRET = (same as web service)
   SESSION_TTL_SECONDS = 86400
   MAX_CONCURRENT_UPDATES = 32
   ```

5. **Click "Deploy Background Worker"**

---

## Step 5: Verify Deployment

### Check Web Service
```bash
curl https://swiggy-bot-web.onrender.com/
```

Expected response:
```json
{
  "status": "online",
  "bot": "Swiggy Cash Loot",
  "admin": "/admin",
  "user": "/user/<chat_id>",
  "api": "/api/stats"
}
```

### Check Worker Logs
1. Go to Render Dashboard
2. Click on `swiggy-bot-worker`
3. Go to **Logs** tab
4. Should see: `🤖 Bot started successfully...`

---

## Step 6: Access Dashboards

### Admin Dashboard
**URL:** `https://swiggy-bot-web.onrender.com/admin/login`

**Login with:**
- Password: (your ADMIN_PASSWORD)

### User Dashboard
**URL:** `https://swiggy-bot-web.onrender.com/user/<chat_id>`

Replace `<chat_id>` with Telegram chat ID

### API Statistics
**URL:** `https://swiggy-bot-web.onrender.com/api/stats`

---

## Step 7: Test Telegram Bot

1. Message your bot on Telegram
2. Click `/start`
3. Should see advanced keyboard
4. Test `/login` command

---

## Step 8: Enable Auto-Deploy (Optional)

Render auto-deploys on push to `main` branch.

To test:
```bash
# Make a change
echo "# Updated" >> README.md

# Commit and push
git add .
git commit -m "Test auto-deploy"
git push origin main
```

Check Render dashboard — deployment should start automatically.

---

## Troubleshooting

### Bot not responding

**Check Worker Logs:**
1. Render Dashboard → `swiggy-bot-worker` → **Logs**
2. Look for errors

**Common issues:**
- `BOT_TOKEN` invalid → Update environment variable
- Worker service crashed → Check logs for exceptions
- Bot is polling but no messages → Give it a few seconds, bot starts polling after deployment

### Web service returning 500 error

**Check Web Service Logs:**
1. Render Dashboard → `swiggy-bot-web` → **Logs**
2. Look for Flask errors

**Common issues:**
- Missing environment variables → Add all vars
- Import errors → Check `requirements.txt` complete

### Admin login not working

- Check `ADMIN_PASSWORD` is set correctly
- Clear browser cookies
- Try incognito/private mode

### Sessions not persisting between restarts

This is expected with Render free tier (ephemeral storage). Use database for production:
```python
# PostgreSQL example
DATABASE_URL = os.getenv("DATABASE_URL")
# Implement session storage in DB instead of files
```

---

## Scaling Beyond Free Tier

### Add Database (PostgreSQL)
1. Render Dashboard → **"New +"** → **"PostgreSQL"**
2. Set name, region
3. Note connection string
4. Update bot to use DB for sessions

### Increase Worker Resources
1. Click on worker service
2. Go to **Settings** → **Instance Type**
3. Upgrade from Starter to Standard ($7/month)

### Multiple Worker Instances
1. Go to service settings
2. Increase **Num Instances** for load distribution

---

## Cost Estimate (Free Tier)

| Service | Cost | Notes |
|---------|------|-------|
| Web Service (Starter) | Free | 0.5 vCPU, 0.5 GB RAM, 100 GB bandwidth |
| Background Worker (Starter) | Free | 0.5 vCPU, 0.5 GB RAM |
| PostgreSQL (Free) | Free | 256 MB, free tier |
| **Total** | **$0/month** | Limitation: spins down after 15 min inactivity |

### Keep Service Alive
To prevent spin-down on free tier, add a ping every 14 minutes:
```bash
# Add to GitHub Actions
name: Keep-Alive
on:
  schedule:
    - cron: '*/14 * * * *'

jobs:
  ping:
    runs-on: ubuntu-latest
    steps:
      - name: Ping Render
        run: curl https://swiggy-bot-web.onrender.com/
```

---

## GitHub Actions Auto-Deploy

Edit `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Render
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Trigger Render Deploy
        run: |
          curl https://api.render.com/deploy/srv-YOUR_SERVICE_ID?key=${{ secrets.RENDER_API_KEY }} \
            -X POST
```

Get `RENDER_API_KEY` and `SERVICE_ID` from Render account settings.

---

## Production Checklist

- ✅ `BOT_TOKEN` is valid
- ✅ `ADMIN_PASSWORD` is strong
- ✅ `FLASK_SECRET` is random
- ✅ Web service is running
- ✅ Worker is polling successfully
- ✅ Admin dashboard accessible
- ✅ Bot responds to commands
- ✅ JSON logs are being created
- ✅ GitHub Actions configured (optional)
- ✅ Keep-Alive cron job set (free tier)

---

## Monitoring

### Daily Checks
```bash
# Check API status
curl https://swiggy-bot-web.onrender.com/api/stats

# Check admin logs
# Visit: https://swiggy-bot-web.onrender.com/admin/login
```

### Set Up Alerts (Optional)
1. Render Dashboard → Service → **Settings** → **Notifications**
2. Enable email alerts for deployment failures

---

**Deployment Complete!** 🚀

Your bot is now running on Render with:
- Web dashboard at `https://swiggy-bot-web.onrender.com`
- Admin panel at `/admin/login`
- Telegram bot polling continuously
- JSON event logging
- Auto-deploy on Git push

---

**Need Help?**
- Render Status: [status.render.com](https://status.render.com)
- Check logs in Render Dashboard
- Review `README.md` troubleshooting section
