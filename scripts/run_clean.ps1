# Script to run Flutter with clean logs (filters Android noise)
# Usage: .\run_clean.ps1

$exclude = @(
    "GoogleApiManager",
    "FlagRegistrar",
    "ProviderInstaller",
    "DynamiteModule",
    "nativeloader",
    "Choreographer",
    "ProfileInstaller",
    "hiddenapi",
    "hiddenapi:",
    "fuov",
    "NativeCrypto",
    "conscrypt",
    "WindowExtensionsImpl",
    "InsetsController",
    "ImeTracker",
    "ApplicationLoaders",
    "HWUI",
    "example.memozap:",
    "AssetManager2",
    "FirebaseAuth: Notifying",
    "LocalRequestInterceptor",
    "Compiler allocated",
    "Background concurrent",
    "Waiting for a blocking",
    "WaitForGcToComplete",
    "Verification of void",
    "W/System",
    "E/GoogleApiManager",
    "W/FlagRegistrar",
    "D/ApplicationLoaders",
    "D/nativeloader",
    "I/example.memozap",
    "W/example.memozap",
    "D/ProfileInstaller",
    "D/FirebaseAuth",
    "D/WindowLayoutComponentImpl",
    "V/NativeCrypto",
    "I/ProviderInstaller",
    "W/ProviderInstaller",
    "D/CompatChangeReporter",
    "I/DynamiteModule",
    "W/DynamiteModule"
)

$pattern = ($exclude | ForEach-Object { [regex]::Escape($_) }) -join '|'

flutter run --endless-trace-buffer 2>&1 | Where-Object { $_ -notmatch $pattern }
