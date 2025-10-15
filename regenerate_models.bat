@echo off
echo Regenerating JSON serialization code for UserEntity...
flutter pub run build_runner build --delete-conflicting-outputs
echo Done!
pause
