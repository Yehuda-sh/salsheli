@echo off
echo.
echo Updating and rebuilding...
echo.
flutter pub upgrade
flutter pub run build_runner build --delete-conflicting-outputs
echo.
echo Done! Press any key to exit...
pause >nul
