@echo off
echo ====================================
echo Installing dependencies...
echo ====================================
flutter pub get

echo.
echo ====================================
echo Running build_runner...
echo ====================================
dart run build_runner build --delete-conflicting-outputs

echo.
echo ====================================
echo Done!
echo ====================================
pause
