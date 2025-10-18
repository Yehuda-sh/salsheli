@echo off
REM ========================================
REM העתקת קובץ תצורה MCP - Salsheli
REM ========================================

echo.
echo ================================================
echo    Copying MCP Config to Claude Desktop
echo ================================================
echo.

REM בדיקה שהקובץ קיים
if not exist "C:\projects\salsheli\claude_desktop_config.json" (
    echo [ERROR] Config file not found!
    echo Please create: C:\projects\salsheli\claude_desktop_config.json
    pause
    exit /b 1
)

REM יצירת תיקייה
if not exist "%APPDATA%\Claude" (
    echo Creating Claude config directory...
    mkdir "%APPDATA%\Claude"
)

REM גיבוי קובץ קיים
if exist "%APPDATA%\Claude\claude_desktop_config.json" (
    echo Backing up existing config...
    copy "%APPDATA%\Claude\claude_desktop_config.json" "%APPDATA%\Claude\claude_desktop_config.json.backup"
)

REM העתקת הקובץ החדש
echo Copying new config...
copy "C:\projects\salsheli\claude_desktop_config.json" "%APPDATA%\Claude\claude_desktop_config.json"

if %errorlevel% neq 0 (
    echo [ERROR] Failed to copy config file
    pause
    exit /b 1
)

echo.
echo ================================================
echo    Success!
echo ================================================
echo.
echo Config copied to: %APPDATA%\Claude
echo.
echo IMPORTANT: Restart Claude Desktop now!
echo.
pause
