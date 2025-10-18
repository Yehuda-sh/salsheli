@echo off
REM ========================================
REM התקנת MCP Servers - Salsheli Project
REM ========================================

echo.
echo ================================================
echo    Installing MCP Servers for Salsheli
echo ================================================
echo.

REM בדיקת Python
echo [1/5] Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found! Install from: https://www.python.org/downloads/
    pause
    exit /b 1
)
echo [OK] Python found

REM בדיקת Node.js
echo.
echo [2/5] Checking Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found! Install from: https://nodejs.org/
    pause
    exit /b 1
)
echo [OK] Node.js found

REM התקנת uv
echo.
echo [3/5] Installing uv (for Git MCP)...
pip install uv
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install uv
    pause
    exit /b 1
)
echo [OK] uv installed

REM התקנת Git MCP
echo.
echo [4/5] Installing Git MCP...
pip install mcp-server-git
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install Git MCP
    pause
    exit /b 1
)
echo [OK] Git MCP installed

REM בדיקת npx
echo.
echo [5/5] Verifying npx...
npx --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npx not found! Check Node.js installation
    pause
    exit /b 1
)
echo [OK] npx ready

echo.
echo ================================================
echo    Installation Complete!
echo ================================================
echo.
echo Next steps:
echo 1. Get API keys:
echo    - GitHub: https://github.com/settings/tokens
echo    - Brave Search: https://brave.com/search/api/
echo.
echo 2. Edit claude_desktop_config.json and add your keys
echo.
echo 3. Copy to: %%APPDATA%%\Claude\claude_desktop_config.json
echo.
echo 4. Restart Claude Desktop
echo.
pause
