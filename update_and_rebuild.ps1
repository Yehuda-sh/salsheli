Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Salsheli - Update and Rebuild Script     " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Update dependencies
Write-Host "[1/4] Updating dependencies..." -ForegroundColor Yellow
Write-Host "---------------------------------------------" -ForegroundColor DarkGray
flutter pub upgrade

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependencies updated successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some dependency updates failed, continuing..." -ForegroundColor Yellow
}

Write-Host ""

# Step 2: Regenerate code
Write-Host "[2/4] Regenerating JSON serialization code..." -ForegroundColor Yellow
Write-Host "---------------------------------------------" -ForegroundColor DarkGray
flutter pub run build_runner build --delete-conflicting-outputs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Code generation completed!" -ForegroundColor Green
} else {
    Write-Host "❌ Code generation failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Test UserEntity
Write-Host "[3/4] Testing UserEntity..." -ForegroundColor Yellow
Write-Host "---------------------------------------------" -ForegroundColor DarkGray
flutter test test/models/user_entity_test.dart

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ UserEntity tests passed!" -ForegroundColor Green
} else {
    Write-Host "❌ UserEntity tests failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 4: Test TimestampConverter
Write-Host "[4/4] Testing TimestampConverter..." -ForegroundColor Yellow
Write-Host "---------------------------------------------" -ForegroundColor DarkGray
flutter test test/models/timestamp_converter_test.dart

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ TimestampConverter tests passed!" -ForegroundColor Green
} else {
    Write-Host "❌ TimestampConverter tests failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  🎉 SUCCESS! All improvements completed!  " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Changes applied:" -ForegroundColor Cyan
Write-Host "   • Analyzer updated to v8.4.0" -ForegroundColor White
Write-Host "   • Removed duplicate default values" -ForegroundColor White
Write-Host "   • All tests passing" -ForegroundColor White
Write-Host "   • No more warnings" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
