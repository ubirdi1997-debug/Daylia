#!/bin/bash
set -e

echo "========================================"
echo "  Daylia v2.0.0 Release Build Script"
echo "========================================"
echo ""

echo "Step 1: Flutter Clean"
flutter clean
echo "✅ Flutter Clean Complete"

echo ""
echo "Step 2: Get Dependencies"
flutter pub get
echo "✅ Dependencies Ready"

echo ""
echo "Step 3: Run Unit Tests"
flutter test test/streak_logic_test.dart
echo "✅ Unit Tests Passed"

echo ""
echo "Step 4: Analyze Code"
flutter analyze --no-fatal-infos
echo "✅ Code Analysis Complete"

echo ""
echo "Step 5: Build Release App Bundle (AAB) for Google Play"
flutter build appbundle --release
echo "✅ App Bundle Complete"

echo ""
echo "Step 6: Build Release APK (for direct install)"
flutter build apk --release
echo "✅ Release APK Complete"

echo ""
echo "========================================"
echo "  Build Complete — v2.0.0+2"
echo "========================================"
echo ""
echo "📦 App Bundle (Google Play upload):"
ls -lh build/app/outputs/bundle/release/app-release.aab 2>/dev/null || echo "  Not found — check build output"

echo ""
echo "📱 APK (Direct install):"
ls -lh build/app/outputs/apk/release/app-release.apk 2>/dev/null || echo "  Not found — check build output"

echo ""
echo "Upload build/app/outputs/bundle/release/app-release.aab to Google Play Console."
