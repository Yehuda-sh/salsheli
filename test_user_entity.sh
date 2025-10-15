#!/bin/bash
# Quick Test Script for UserEntity

echo "🔧 Step 1: Regenerating code..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "🧪 Step 2: Running UserEntity tests..."
flutter test test/models/user_entity_test.dart

echo ""
echo "✅ Done! Check results above."
