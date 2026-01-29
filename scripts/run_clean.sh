#!/bin/bash
# Script to run Flutter with clean logs (filters Android noise)
# Usage: ./run_clean.sh

flutter run --endless-trace-buffer 2>&1 | grep -v \
    -e "GoogleApiManager" \
    -e "FlagRegistrar" \
    -e "ProviderInstaller" \
    -e "DynamiteModule" \
    -e "nativeloader" \
    -e "Choreographer" \
    -e "ProfileInstaller" \
    -e "hiddenapi" \
    -e "hiddenapi:" \
    -e "fuov" \
    -e "NativeCrypto" \
    -e "conscrypt" \
    -e "WindowExtensionsImpl" \
    -e "InsetsController" \
    -e "ImeTracker" \
    -e "ApplicationLoaders" \
    -e "HWUI" \
    -e "example.memozap:" \
    -e "AssetManager2" \
    -e "FirebaseAuth: Notifying" \
    -e "LocalRequestInterceptor" \
    -e "Compiler allocated" \
    -e "Background concurrent" \
    -e "Waiting for a blocking" \
    -e "WaitForGcToComplete" \
    -e "Verification of void" \
    -e "W/System" \
    -e "E/GoogleApiManager" \
    -e "W/FlagRegistrar" \
    -e "D/ApplicationLoaders" \
    -e "D/nativeloader" \
    -e "I/example.memozap" \
    -e "W/example.memozap" \
    -e "D/ProfileInstaller" \
    -e "D/FirebaseAuth" \
    -e "D/WindowLayoutComponentImpl" \
    -e "V/NativeCrypto" \
    -e "I/ProviderInstaller" \
    -e "W/ProviderInstaller" \
    -e "D/CompatChangeReporter" \
    -e "I/DynamiteModule" \
    -e "W/DynamiteModule"
