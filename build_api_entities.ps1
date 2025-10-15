# ==========================================
# Salsheli Build API Entities Script
# Version: 2.0
# Updated: 15/10/2025
# ==========================================

param(
    [string]$Mode = "full",  # full, clean, build, analyze, format
    [switch]$Verbose = $false
)

# ==========================================
# Configuration
# ==========================================
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

$colors = @{
    Header    = "Cyan"
    Success   = "Green"
    Warning   = "Yellow"
    Error     = "Red"
    Info      = "Blue"
    Muted     = "Gray"
}

# ==========================================
# Functions
# ==========================================

function Write-Section {
    param([string]$Title, [string]$Icon = "🔧")
    Write-Host "`n" + ("=" * 50) -ForegroundColor $colors.Muted
    Write-Host "$Icon $Title" -ForegroundColor $colors.Header
    Write-Host ("=" * 50) -ForegroundColor $colors.Muted
}

function Write-Step {
    param([string]$Message, [string]$Icon = "•")
    Write-Host "  $Icon $Message" -ForegroundColor $colors.Info
}

function Write-Success {
    param([string]$Message, [string]$Icon = "✅")
    Write-Host "  $Icon $Message" -ForegroundColor $colors.Success
}

function Write-Warning-Msg {
    param([string]$Message, [string]$Icon = "⚠️ ")
    Write-Host "  $Icon $Message" -ForegroundColor $colors.Warning
}

function Write-Error-Msg {
    param([string]$Message, [string]$Icon = "❌")
    Write-Host "  $Icon $Message" -ForegroundColor $colors.Error
}

function Invoke-Command-Safe {
    param([string]$Command, [string]$Description)
    
    Write-Step $Description
    
    try {
        if ($Verbose) {
            Invoke-Expression $Command
        } else {
            Invoke-Expression $Command 2>$null | Out-Null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Successfully completed: $Description"
            return $true
        } else {
            Write-Error-Msg "Failed: $Description (Exit code: $LASTEXITCODE)"
            return $false
        }
    }
    catch {
        Write-Error-Msg "Error: $($_.Exception.Message)"
        return $false
    }
}

function Show-Menu {
    Write-Section "Choose Build Mode" "📋"
    Write-Host "`n  1. Full Build (clean + pub get + build_runner + analyze)" -ForegroundColor $colors.Info
    Write-Host "  2. Quick Build (pub get + build_runner only)" -ForegroundColor $colors.Info
    Write-Host "  3. Clean (flutter clean)" -ForegroundColor $colors.Info
    Write-Host "  4. Build Runner Only" -ForegroundColor $colors.Info
    Write-Host "  5. Analyze Code" -ForegroundColor $colors.Info
    Write-Host "  6. Format Code" -ForegroundColor $colors.Info
    Write-Host "  7. Check Environment" -ForegroundColor $colors.Info
    Write-Host "  8. Exit" -ForegroundColor $colors.Error
    Write-Host "`n"
}

function Check-Environment {
    Write-Section "Environment Check" "🔍"
    
    Write-Step "Checking Flutter..."
    $flutterVersion = flutter --version 2>$null
    if ($?) {
        Write-Success "Flutter found"
        Write-Host "    $($flutterVersion.Split([Environment]::NewLine)[0])" -ForegroundColor $colors.Muted
    } else {
        Write-Error-Msg "Flutter not found"
        return $false
    }
    
    Write-Step "Checking Dart..."
    $dartVersion = dart --version 2>$null
    if ($?) {
        Write-Success "Dart found"
        Write-Host "    $dartVersion" -ForegroundColor $colors.Muted
    } else {
        Write-Error-Msg "Dart not found"
        return $false
    }
    
    Write-Step "Checking pubspec.yaml..."
    if (Test-Path "pubspec.yaml") {
        Write-Success "pubspec.yaml found"
    } else {
        Write-Error-Msg "pubspec.yaml not found"
        return $false
    }
    
    Write-Success "Environment check passed!"
    return $true
}

function Full-Build {
    Write-Section "Full Build Process" "🔄"
    
    # Step 1: Clean
    Write-Host "`n📍 Step 1/4: Cleaning..." -ForegroundColor $colors.Header
    if (-not (Invoke-Command-Safe "flutter clean" "Removing build artifacts")) {
        Write-Error-Msg "Cleaning failed!"
        return $false
    }
    
    # Step 2: Pub Get
    Write-Host "`n📍 Step 2/4: Installing dependencies..." -ForegroundColor $colors.Header
    if (-not (Invoke-Command-Safe "flutter pub get" "Installing dependencies")) {
        Write-Error-Msg "Pub get failed!"
        return $false
    }
    
    # Step 3: Build Runner
    Write-Host "`n📍 Step 3/4: Generating code..." -ForegroundColor $colors.Header
    if (-not (Invoke-Command-Safe "dart run build_runner build --delete-conflicting-outputs" "Running build_runner")) {
        Write-Error-Msg "Build runner failed!"
        return $false
    }
    
    # Step 4: Analyze
    Write-Host "`n📍 Step 4/4: Analyzing code..." -ForegroundColor $colors.Header
    if (-not (Invoke-Command-Safe "flutter analyze" "Analyzing code")) {
        Write-Warning-Msg "Code analysis found issues (see above)"
    }
    
    return $true
}

function Quick-Build {
    Write-Section "Quick Build" "⚡"
    
    # Step 1: Pub Get
    Write-Host "`n📍 Step 1/2: Installing dependencies..." -ForegroundColor $colors.Header
    if (-not (Invoke-Command-Safe "flutter pub get" "Installing dependencies")) {
        Write-Error-Msg "Pub get failed!"
        return $false
    }
    
    # Step 2: Build Runner
    Write-Host "`n📍 Step 2/2: Generating code..." -ForegroundColor $colors.Header
    if (-not (Invoke-Command-Safe "dart run build_runner build --delete-conflicting-outputs" "Running build_runner")) {
        Write-Error-Msg "Build runner failed!"
        return $false
    }
    
    return $true
}

function Clean-Only {
    Write-Section "Cleaning" "🧹"
    if (-not (Invoke-Command-Safe "flutter clean" "Removing build artifacts")) {
        Write-Error-Msg "Cleaning failed!"
        return $false
    }
    return $true
}

function BuildRunner-Only {
    Write-Section "Build Runner" "⚙️"
    if (-not (Invoke-Command-Safe "dart run build_runner build --delete-conflicting-outputs" "Running build_runner")) {
        Write-Error-Msg "Build runner failed!"
        return $false
    }
    return $true
}

function Analyze-Only {
    Write-Section "Code Analysis" "🔍"
    if (-not (Invoke-Command-Safe "flutter analyze" "Analyzing code")) {
        Write-Warning-Msg "Code analysis found issues"
    }
}

function Format-Only {
    Write-Section "Code Formatting" "📝"
    if (-not (Invoke-Command-Safe "dart format lib/ -w" "Formatting code")) {
        Write-Error-Msg "Code formatting failed!"
        return $false
    }
    return $true
}

function Show-Results {
    param([bool]$Success)
    
    Write-Section "Build Summary" "📊"
    
    if ($Success) {
        Write-Success "Build completed successfully!" "✨"
        Write-Host "`n✅ All steps completed without errors" -ForegroundColor $colors.Success
    } else {
        Write-Error-Msg "Build failed!" "❌"
        Write-Host "`n⚠️  Check error messages above for details" -ForegroundColor $colors.Warning
    }
    
    Write-Host "`n📍 Next steps:" -ForegroundColor $colors.Header
    Write-Host "  • flutter run    → Run the app in development mode" -ForegroundColor $colors.Muted
    Write-Host "  • flutter test   → Run unit tests" -ForegroundColor $colors.Muted
    Write-Host "  • flutter build  → Build for production" -ForegroundColor $colors.Muted
    Write-Host "`n"
}

# ==========================================
# Main Script
# ==========================================

$success = $false

switch ($Mode.ToLower()) {
    "full" {
        if (Check-Environment) {
            $success = Full-Build
        }
        break
    }
    "quick" {
        if (Check-Environment) {
            $success = Quick-Build
        }
        break
    }
    "clean" {
        $success = Clean-Only
        break
    }
    "build" {
        if (Check-Environment) {
            $success = BuildRunner-Only
        }
        break
    }
    "analyze" {
        Analyze-Only
        $success = $true
        break
    }
    "format" {
        $success = Format-Only
        break
    }
    "menu" {
        do {
            Show-Menu
            $choice = Read-Host "Enter choice (1-8)"
            
            switch ($choice) {
                "1" { $success = Full-Build; break }
                "2" { $success = Quick-Build; break }
                "3" { $success = Clean-Only; break }
                "4" { $success = BuildRunner-Only; break }
                "5" { Analyze-Only; $success = $true; break }
                "6" { $success = Format-Only; break }
                "7" { $success = Check-Environment; break }
                "8" { Write-Host "👋 Goodbye!`n" -ForegroundColor $colors.Success; exit 0 }
                default { Write-Warning-Msg "Invalid choice. Please try again."; $choice = "invalid" }
            }
            
            if ($choice -ne "invalid") {
                Show-Results $success
                Write-Host "Press any key to continue..." -ForegroundColor $colors.Muted
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        } while ($true)
    }
    default {
        Write-Error-Msg "Unknown mode: $Mode"
        Write-Host "`nUsage: .\build_api_entities.ps1 -Mode [full|quick|clean|build|analyze|format|menu]" -ForegroundColor $colors.Info
        Write-Host "       .\build_api_entities.ps1 -Mode menu -Verbose`n" -ForegroundColor $colors.Muted
        exit 1
    }
}

Show-Results $success

if (-not $success) {
    exit 1
}
