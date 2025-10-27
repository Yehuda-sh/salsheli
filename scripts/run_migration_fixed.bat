@echo off
REM ==============================================
REM Migration Runner: "super" -> "supermarket"
REM ==============================================

echo.
echo ================================================
echo  MemoZap - List Types Migration
echo ================================================
echo.
echo Step 1: Cleaning and getting dependencies...
echo.

cd ..
call flutter clean
call flutter pub get

echo.
echo Step 2: Running migration...
echo.

dart scripts/migrate_list_types.dart

echo.
echo ================================================
echo Migration completed!
echo Check the output above for results.
echo ================================================
echo.
pause
