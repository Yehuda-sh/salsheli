@echo off
REM Build models first
echo Building models...
flutter pub run build_runner build --delete-conflicting-outputs

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Models built successfully!
echo ========================================
echo.
echo Ready to run migration script.
echo Run: dart run scripts/migrate_list_types.dart
echo.
pause
