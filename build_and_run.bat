@echo off
REM ==========================================
REM Build & Run Script for Salsheli
REM Version: 2.1
REM Updated: 22/10/2025
REM ==========================================

setlocal enabledelayedexpansion

REM ==========================================
REM Startup Checks
REM ==========================================

REM Check if Flutter is installed
where flutter >nul 2>nul
if errorlevel 1 (
    echo.
    echo ❌ Flutter not found!
    echo 💡 Please install Flutter first: https://flutter.dev
    echo.
    pause
    exit /b 1
)

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo.
    echo ❌ Not in a Flutter project directory!
    echo 💡 Please run this script from: C:\projects\salsheli\
    echo.
    pause
    exit /b 1
)

:menu
cls
echo.
echo ╔════════════════════════════════════════╗
echo ║     🛒 Salsheli Build & Run Menu       ║
echo ╚════════════════════════════════════════╝
echo.
echo 1. 🔧 Clean + Setup (pub get + build_runner)
echo 2. ▶️  Run Development (Debug mode)
echo 3. 🔍 Analyze Code (flutter analyze)
echo 4. 📝 Format Code (dart format)
echo 5. 🏗️  Build APK (Release)
echo 6. 📦 Build App Bundle (Release)
echo 7. 🔄 Full Setup + Run (all steps)
echo 8. 🧪 Run Tests (flutter test)
echo 9. ❌ Exit
echo.
set /p choice="Choose an option (1-9): "

if "%choice%"=="1" goto clean_setup
if "%choice%"=="2" goto run_debug
if "%choice%"=="3" goto analyze
if "%choice%"=="4" goto format
if "%choice%"=="5" goto build_apk
if "%choice%"=="6" goto build_bundle
if "%choice%"=="7" goto full_setup
if "%choice%"=="8" goto run_tests
if "%choice%"=="9" goto end
echo Invalid choice. Please try again.
timeout /t 2 >nul
goto menu

REM ==========================================
REM Option 1: Clean Setup
REM ==========================================
:clean_setup
cls
echo.
echo ====================================
echo 🔧 CLEAN SETUP
echo ====================================
echo.

echo 📦 Running: flutter clean
flutter clean
if errorlevel 1 (
    echo ❌ Error during flutter clean
    pause
    goto menu
)

echo.
echo 📥 Running: flutter pub get
flutter pub get
if errorlevel 1 (
    echo ❌ Error during flutter pub get
    pause
    goto menu
)

echo.
echo 🔨 Running: build_runner
dart run build_runner build --delete-conflicting-outputs
if errorlevel 1 (
    echo ❌ Error during build_runner
    pause
    goto menu
)

echo.
echo ✅ Clean setup completed successfully!
pause
goto menu

REM ==========================================
REM Option 2: Run Development
REM ==========================================
:run_debug
cls
echo.
echo ====================================
echo ▶️  RUN DEVELOPMENT (Debug mode)
echo ====================================
echo.

echo 🚀 Starting Flutter development build...
echo 💡 Tip: Press 'r' for hot reload, 'R' for hot restart
echo.
flutter run -v
if errorlevel 1 (
    echo.
    echo ❌ Error during flutter run
    echo 💡 Tip: Check if device is connected - run: flutter devices
    pause
    goto menu
)

pause
goto menu

REM ==========================================
REM Option 3: Analyze Code
REM ==========================================
:analyze
cls
echo.
echo ====================================
echo 🔍 CODE ANALYSIS
echo ====================================
echo.

echo 📊 Running: flutter analyze
flutter analyze

if errorlevel 1 (
    echo ⚠️  Analysis found issues. See above.
) else (
    echo ✅ Code analysis passed! (0 issues)
)

pause
goto menu

REM ==========================================
REM Option 4: Format Code
REM ==========================================
:format
cls
echo.
echo ====================================
echo 📝 CODE FORMATTING
echo ====================================
echo.

echo 🎨 Running: dart format lib/ -w
dart format lib/ -w

echo.
echo ✅ Code formatted successfully!
pause
goto menu

REM ==========================================
REM Option 5: Build APK
REM ==========================================
:build_apk
cls
echo.
echo ====================================
echo 🏗️  BUILD APK (Release)
echo ====================================
echo.

echo ⏳ This may take several minutes...
flutter build apk --release

if errorlevel 1 (
    echo ❌ Error during APK build
    pause
    goto menu
)

echo.
echo ✅ APK built successfully!
echo 📍 Location: build\app\outputs\flutter-apk\app-release.apk
pause
goto menu

REM ==========================================
REM Option 6: Build App Bundle
REM ==========================================
:build_bundle
cls
echo.
echo ====================================
echo 📦 BUILD APP BUNDLE (Release)
echo ====================================
echo.

echo ⏳ This may take several minutes...
flutter build appbundle --release

if errorlevel 1 (
    echo ❌ Error during app bundle build
    pause
    goto menu
)

echo.
echo ✅ App bundle built successfully!
echo 📍 Location: build\app\outputs\bundle\release\app-release.aab
pause
goto menu

REM ==========================================
REM Option 7: Full Setup + Run
REM ==========================================
:full_setup
cls
echo.
echo ====================================
echo 🔄 FULL SETUP + RUN
echo ====================================
echo.

echo 📦 Step 1/4: flutter clean
flutter clean
if errorlevel 1 (
    echo ❌ Error during flutter clean
    pause
    goto menu
)

echo.
echo 📥 Step 2/4: flutter pub get
flutter pub get
if errorlevel 1 (
    echo ❌ Error during flutter pub get
    pause
    goto menu
)

echo.
echo 🔨 Step 3/4: build_runner
dart run build_runner build --delete-conflicting-outputs
if errorlevel 1 (
    echo ❌ Error during build_runner
    pause
    goto menu
)

echo.
echo 🔍 Step 4/4: flutter analyze
flutter analyze
if errorlevel 1 (
    echo ⚠️  Analysis found issues (see above)
    echo.
    echo Continuing to run anyway...
)

echo.
echo ✅ Setup completed!
echo.
echo 🚀 Starting Flutter app...
flutter run -v

pause
goto menu

REM ==========================================
REM Option 8: Run Tests
REM ==========================================
:run_tests
cls
echo.
echo ====================================
echo 🧪 RUN TESTS
echo ====================================
echo.

echo 🔬 Running: flutter test
flutter test

if errorlevel 1 (
    echo.
    echo ⚠️  Some tests failed. See above for details.
) else (
    echo.
    echo ✅ All tests passed!
)

pause
goto menu

REM ==========================================
REM Exit
REM ==========================================
:end
echo.
echo 👋 Goodbye!
echo.
exit /b 0
