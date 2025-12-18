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
    "hiddenapi:",
    "W/System",
    "E/GoogleApiManager",
    "W/FlagRegistrar"
)

$pattern = ($exclude | ForEach-Object { [regex]::Escape($_) }) -join '|'

flutter run 2>&1 | Where-Object { $_ -notmatch $pattern }
