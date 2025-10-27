@echo off
REM ==============================================
REM Migration Runner: "super" -> "supermarket"
REM ==============================================

echo.
echo ================================================
echo  MemoZap - List Types Migration
echo ================================================
echo.
echo This will update all shopping lists in Firebase:
echo   "super" --^> "supermarket"
echo.
echo Press Ctrl+C to cancel, or
pause

echo.
echo Running migration...
echo.

dart run migrate_list_types.dart

echo.
echo ================================================
echo Migration completed!
echo Check the output above for results.
echo ================================================
echo.
pause
