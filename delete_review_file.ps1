# 🗑️ מחיקת קובץ תיעוד ישן - PowerShell
# תאריך: 06/10/2025

Write-Host "🗑️ מוחק UNUSED_FILES_REVIEW.md..." -ForegroundColor Yellow

$file = "UNUSED_FILES_REVIEW.md"
$fullPath = Join-Path $PSScriptRoot $file

if (Test-Path $fullPath) {
    try {
        Remove-Item $fullPath -Force
        Write-Host "✅ נמחק: $file" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ שגיאה: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "⚠️  לא נמצא: $file" -ForegroundColor Yellow
}

Write-Host "✨ הושלם!" -ForegroundColor Green
Write-Host ""
Write-Host "⏳ הסקריפט ימחק את עצמו בעוד 2 שניות..."
Start-Sleep -Seconds 2
Remove-Item $PSCommandPath -Force
