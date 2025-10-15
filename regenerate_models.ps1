Write-Host "🔧 Regenerating JSON serialization code..." -ForegroundColor Cyan
Write-Host "This may take a moment..." -ForegroundColor Yellow

# Run build_runner
flutter pub run build_runner build --delete-conflicting-outputs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Success! Code generation completed." -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Next steps:" -ForegroundColor Cyan
    Write-Host "1. Run tests: flutter test test/models/user_entity_test.dart" -ForegroundColor White
    Write-Host "2. All tests should pass now!" -ForegroundColor White
} else {
    Write-Host "❌ Error during code generation!" -ForegroundColor Red
    Write-Host "Please check the output above for details." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
