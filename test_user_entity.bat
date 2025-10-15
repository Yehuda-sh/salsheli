@echo off
cls
echo ============================================
echo   UserEntity Fix and Test Script
echo ============================================
echo.

echo [1/2] Regenerating JSON serialization code...
echo ---------------------------------------------
call flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Code generation failed!
    goto :error
)

echo.
echo [2/2] Running UserEntity tests...
echo ---------------------------------------------
call flutter test test/models/user_entity_test.dart
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Some tests failed!
    goto :error
)

echo.
echo ============================================
echo   SUCCESS! All tests passed!
echo ============================================
goto :end

:error
echo.
echo ============================================
echo   FAILED! Please check errors above
echo ============================================

:end
echo.
pause
