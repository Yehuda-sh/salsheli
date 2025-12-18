@echo off
REM Script to run Flutter with filtered Android logs
REM Usage: run_filtered.bat

flutter run 2>&1 | findstr /V /C:"GoogleApiManager" /C:"FlagRegistrar" /C:"ProviderInstaller" /C:"DynamiteModule" /C:"nativeloader" /C:"Choreographer" /C:"ProfileInstaller" /C:"hiddenapi" /C:"fuov" /C:"NativeCrypto" /C:"conscrypt" /C:"WindowExtensionsImpl" /C:"InsetsController" /C:"ImeTracker" /C:"ApplicationLoaders" /C:"HWUI" /C:"example.memozap" /C:"AssetManager2" /C:"FirebaseAuth: Notifying" /C:"LocalRequestInterceptor" /C:"Compiler allocated" /C:"Background concurrent"
