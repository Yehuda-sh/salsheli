Write-Host "🔧 מריץ build_runner..." -ForegroundColor Cyan

# נקה קבצים ישנים
Write-Host "`n🧹 מנקה קבצים ישנים..." -ForegroundColor Yellow
flutter clean

# התקנת תלויות
Write-Host "`n📦 מתקין תלויות..." -ForegroundColor Yellow
flutter pub get

# הרצת build_runner
Write-Host "`n⚙️ יוצר קבצי .g.dart..." -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs

# בדיקת שגיאות
Write-Host "`n✅ בודק שגיאות..." -ForegroundColor Yellow
flutter analyze

Write-Host "`n✨ סיום!" -ForegroundColor Green
