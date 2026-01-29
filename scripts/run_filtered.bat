@echo off
REM Script to run Flutter with filtered Android logs
REM Usage: run_filtered.bat

flutter run --endless-trace-buffer 2>&1 | findstr /V ^
 /C:"GoogleApiManager" ^
 /C:"FlagRegistrar" ^
 /C:"ProviderInstaller" ^
 /C:"DynamiteModule" ^
 /C:"nativeloader" ^
 /C:"Choreographer" ^
 /C:"ProfileInstaller" ^
 /C:"hiddenapi" ^
 /C:"hiddenapi:" ^
 /C:"fuov" ^
 /C:"NativeCrypto" ^
 /C:"conscrypt" ^
 /C:"WindowExtensionsImpl" ^
 /C:"InsetsController" ^
 /C:"ImeTracker" ^
 /C:"ApplicationLoaders" ^
 /C:"HWUI" ^
 /C:"example.memozap:" ^
 /C:"AssetManager2" ^
 /C:"FirebaseAuth: Notifying" ^
 /C:"LocalRequestInterceptor" ^
 /C:"Compiler allocated" ^
 /C:"Background concurrent" ^
 /C:"Waiting for a blocking" ^
 /C:"WaitForGcToComplete" ^
 /C:"Verification of void" ^
 /C:"W/System" ^
 /C:"E/GoogleApiManager" ^
 /C:"W/FlagRegistrar" ^
 /C:"D/ApplicationLoaders" ^
 /C:"D/nativeloader" ^
 /C:"I/example.memozap" ^
 /C:"W/example.memozap" ^
 /C:"D/ProfileInstaller" ^
 /C:"D/FirebaseAuth" ^
 /C:"D/WindowLayoutComponentImpl" ^
 /C:"V/NativeCrypto" ^
 /C:"I/ProviderInstaller" ^
 /C:"W/ProviderInstaller" ^
 /C:"D/CompatChangeReporter" ^
 /C:"I/DynamiteModule" ^
 /C:"W/DynamiteModule"
