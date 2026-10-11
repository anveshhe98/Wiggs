#!/bin/bash

# Swiggy Bot Upgrade — One-Command Setup
# ═══════════════════════════════════════════════════════════════

set -e

echo "🚀 Swiggy Cash Loot Bot — Setup Script"
echo "═══════════════════════════════════════════════════════════════"

# 1. Check Python version
echo ""
echo "✓ Checking Python..."
python_version=$(python3 --version 2>&1 | awk '{print $2}')
echo "  Python version: $python_version"

if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)"; then
    echo "❌ Python 3.8+ required"
    exit 1
fi

# 2. Create virtual environment
echo ""
echo "✓ Creating virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "  Virtual environment created"
else
    echo "  Virtual environment already exists"
fi

# Activate virtual environment
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# 3. Upgrade pip
echo ""
echo "✓ Upgrading pip..."
pip install --upgrade pip > /dev/null 2>&1

# 4. Install dependencies
echo ""
echo "✓ Installing dependencies..."
pip install -r requirements.txt > /dev/null 2>&1
echo "  Dependencies installed"

# 5. Create .env file if not exists
echo ""
echo "✓ Setting up environment variables..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "  .env file created from .env.example"
    echo "  ⚠️  Edit .env and add your BOT_TOKEN and ADMIN_PASSWORD"
else
    echo "  .env file already exists"
fi

# 6. Create directories
echo ""
echo "✓ Creating directories..."
mkdir -p tg_sessions
mkdir -p logs
echo "  Directories ready"

# 7. Generate Flask secret if not in .env
echo ""
echo "✓ Checking Flask secret..."
if ! grep -q "FLASK_SECRET=" .env || grep "FLASK_SECRET=" .env | grep -q "your_secret"; then
    secret=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    sed -i.bak "s/FLASK_SECRET=your_secret_key_here/FLASK_SECRET=$secret/" .env
    echo "  Flask secret generated"
else
    echo "  Flask secret already set"
fi

# 8. Check bot token
echo ""
echo "✓ Checking BOT_TOKEN..."
if grep -q "BOT_TOKEN=your_bot_token_here" .env; then
    echo "  ⚠️  BOT_TOKEN not configured"
    echo "  Get your token from: https://t.me/BotFather"
    echo "  Then edit .env and add: BOT_TOKEN=your_actual_token"
else
    echo "  ✅ BOT_TOKEN configured"
fi

# 9. Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Edit .env file if needed:"
echo "   nano .env  (or use your editor)"
echo ""
echo "2. Start the bot:"
echo "   python bot_upgraded.py"
echo ""
echo "3. In another terminal, start Flask:"
echo "   gunicorn --bind 0.0.0.0:5000 bot_upgraded:app"
echo ""
echo "4. Or use Docker Compose:"
echo "   docker-compose up -d"
echo ""
echo "📊 Access dashboards:"
echo "   Admin:  http://localhost:5000/admin/login"
echo "   API:    http://localhost:5000/api/stats"
echo ""
echo "🔗 Telegram bot ready to receive messages!"
echo "═══════════════════════════════════════════════════════════════"
