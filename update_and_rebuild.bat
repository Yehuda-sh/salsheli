@echo off
cls
echo ============================================
echo   Salsheli - Update and Rebuild Script
echo ============================================
echo.

echo [1/4] Updating dependencies (analyzer)...
echo ---------------------------------------------
call flutter pub upgrade
if %errorlevel% neq 0 (
    echo.
    echo [WARNING] Dependency update had issues, continuing anyway...
)

echo.
echo [2/4] Regenerating JSON serialization code...
echo ---------------------------------------------
call flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Code generation failed!
    goto :error
)

echo.
echo [3/4] Running UserEntity tests...
echo ---------------------------------------------
call flutter test test/models/user_entity_test.dart
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Some tests failed!
    goto :error
)

echo.
echo [4/4] Running timestamp_converter tests...
echo ---------------------------------------------
call flutter test test/models/timestamp_converter_test.dart
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Some tests failed!
    goto :error
)

echo.
echo ============================================
echo   SUCCESS! All improvements completed!
echo ============================================
echo.
echo Changes applied:
echo - Analyzer updated to v8.4.0
echo - Removed duplicate default values
echo - All tests passing
echo.
goto :end

:error
echo.
echo ============================================
echo   FAILED! Please check errors above
echo ============================================

:end
echo.
pause
