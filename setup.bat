@echo off
REM Swiggy Bot Upgrade - Windows Setup Script
REM ═════════════════════════════════════════════════════════════

echo.
echo 🚀 Swiggy Cash Loot Bot - Windows Setup
echo ═════════════════════════════════════════════════════════════
echo.

REM Check Python
echo ✓ Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found! Download from https://www.python.org/
    pause
    exit /b 1
)
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo   Python version: %PYTHON_VERSION%
echo.

REM Create virtual environment
echo ✓ Creating virtual environment...
if not exist "venv" (
    python -m venv venv
    echo   Virtual environment created
) else (
    echo   Virtual environment already exists
)
echo.

REM Activate virtual environment
echo ✓ Activating virtual environment...
call venv\Scripts\activate.bat
echo.

REM Upgrade pip
echo ✓ Upgrading pip...
python -m pip install --upgrade pip >nul 2>&1
echo.

REM Install dependencies
echo ✓ Installing dependencies...
pip install -r requirements.txt >nul 2>&1
echo   Dependencies installed
echo.

REM Create .env file
echo ✓ Setting up environment variables...
if not exist ".env" (
    copy .env.example .env >nul
    echo   .env file created
    echo   ⚠️  Edit .env and add your BOT_TOKEN and ADMIN_PASSWORD
) else (
    echo   .env file already exists
)
echo.

REM Create directories
echo ✓ Creating directories...
if not exist "tg_sessions" mkdir tg_sessions
if not exist "logs" mkdir logs
echo   Directories ready
echo.

REM Generate Flask secret
echo ✓ Checking Flask secret...
findstr /m "FLASK_SECRET=your_secret" .env >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%i in ('python -c "import secrets; print(secrets.token_hex(32))"') do set SECRET=%%i
    powershell -Command "(Get-Content .env) -replace 'FLASK_SECRET=your_secret_key_here', 'FLASK_SECRET=%SECRET%' | Set-Content .env"
    echo   Flask secret generated
) else (
    echo   Flask secret already set
)
echo.

REM Check BOT_TOKEN
echo ✓ Checking BOT_TOKEN...
findstr /m "BOT_TOKEN=your_bot_token_here" .env >nul 2>&1
if not errorlevel 1 (
    echo   ⚠️  BOT_TOKEN not configured
    echo   Get your token from: https://t.me/BotFather
    echo   Edit .env and add: BOT_TOKEN=your_actual_token
) else (
    echo   ✅ BOT_TOKEN configured
)
echo.

REM Summary
echo ═════════════════════════════════════════════════════════════
echo ✅ Setup complete!
echo.
echo 📝 Next steps:
echo.
echo 1. Edit .env file if needed:
echo    notepad .env
echo.
echo 2. Start the bot (in activated venv):
echo    python bot_upgraded.py
echo.
echo 3. In another terminal, start Flask:
echo    gunicorn --bind 0.0.0.0:5000 bot_upgraded:app
echo.
echo 4. Or use Docker:
echo    docker-compose up -d
echo.
echo 📊 Access dashboards:
echo    Admin:  http://localhost:5000/admin/login
echo    API:    http://localhost:5000/api/stats
echo.
echo 🔗 Telegram bot ready to receive messages!
echo ═════════════════════════════════════════════════════════════
echo.
pause
