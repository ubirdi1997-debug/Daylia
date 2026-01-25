#!/bin/bash
set -e

echo "Step 1: Flutter Clean"
flutter clean
echo "✅ Flutter Clean Complete"

echo ""
echo "Step 2: Create Release APK"
flutter build apk --release
echo "✅ Release APK Complete"

echo ""
echo "Step 3: Create App Bundle"
flutter build appbundle --release
echo "✅ App Bundle Complete"

echo ""
echo "All builds complete!"
ls -lh build/app/outputs/apk/release/ 2>/dev/null || echo "APK location check"
ls -lh build/app/outputs/bundle/release/ 2>/dev/null || echo "Bundle location check"
