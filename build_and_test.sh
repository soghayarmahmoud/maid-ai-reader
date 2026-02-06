#!/bin/bash

# Build and Test Script for Maid AI Reader

echo "=========================================="
echo "Building Release APK..."
echo "=========================================="

cd "g:\flutter_work\maid-ai-reader-main"

# Clean build
echo "Cleaning build artifacts..."
flutter clean
flutter pub get

# Build release APK
echo "Building release APK..."
flutter build apk --release -v

# Check APK size
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
    echo ""
    echo "✓ APK built successfully!"
    echo "APK Size: $SIZE"
    echo "APK Path: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "✗ APK build failed!"
    exit 1
fi

echo ""
echo "=========================================="
echo "Build Analysis Complete"
echo "=========================================="
