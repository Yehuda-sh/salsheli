@echo off
cls
echo ============================================
echo   Fixing Dependencies and Rebuilding...
echo ============================================
echo.
echo Note: Using analyzer 6.4.1 (compatible with hive_generator)
echo.

echo [1/3] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 goto :error

echo.
echo [2/3] Regenerating code...
call flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 goto :error

echo.
echo [3/3] Running tests...
call flutter test test/models/user_entity_test.dart
if %errorlevel% neq 0 goto :error

echo.
echo ============================================
echo   SUCCESS! Everything works!
echo ============================================
goto :end

:error
echo.
echo ============================================
echo   ERROR! Check the output above
echo ============================================

:end
echo.
pause
