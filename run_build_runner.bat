@echo off
echo ========================================
echo  Running build_runner for ShoppingList
echo ========================================
echo.

cd /d "%~dp0"

echo Step 1: Cleaning previous builds...
call flutter pub run build_runner clean
echo.

echo Step 2: Generating code...
call flutter pub run build_runner build --delete-conflicting-outputs
echo.

echo ========================================
echo  Build runner completed!
echo ========================================
pause
