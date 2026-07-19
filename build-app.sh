#!/bin/bash
set -e

echo "1. Building Swift project in release mode..."
cd macos-App
swift build -c release
cd ..

echo "2. Creating App Bundle structure..."
APP_DIR="Local RTMP Server.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

echo "3. Copying binaries..."
cp macos-App/.build/release/LocalRTMPServer "$APP_DIR/Contents/MacOS/Local RTMP Server"
cp build/server-backend "$APP_DIR/Contents/MacOS/server-backend"

echo "4. Copying app icon and Info.plist..."
cp build/icon.icns "$APP_DIR/Contents/Resources/AppIcon.icns"
cp build/Info.plist "$APP_DIR/Contents/Info.plist"

echo "5. Code signing (local ad-hoc sign)..."
codesign --force --deep --sign - "$APP_DIR"

echo "Build complete! App bundle created at: $APP_DIR"
