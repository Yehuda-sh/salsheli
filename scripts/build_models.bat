@echo off
REM 🎯 Build Script for Salsheli Models - Windows Version
REM Run this after updating models to generate .g.dart files

echo 🔨 Running build_runner...
echo.

cd C:\projects\salsheli
flutter pub run build_runner build --delete-conflicting-outputs

echo.
echo ✅ Build complete!
echo.
echo 📝 Generated files:
echo    - lib/models/active_shopper.g.dart
echo    - lib/models/shopping_list.g.dart (updated)
echo    - lib/models/receipt.g.dart (updated)
echo.
echo 🚀 Next steps:
echo    1. Check for any build errors
echo    2. Commit the changes
echo    3. Move to Phase 2 - Provider Logic
echo.
pause
