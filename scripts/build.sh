#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/.build"
APP_NAME="Scry"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "Building Scry..."

# Build release binaries
cd "$PROJECT_DIR"
swift build -c release --product Scry
swift build -c release --product scry
swift build -c release --product scry-mcp

# Create app bundle structure
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy binaries
cp "$BUILD_DIR/release/Scry" "$APP_BUNDLE/Contents/MacOS/"
cp "$BUILD_DIR/release/scry" "$APP_BUNDLE/Contents/MacOS/"
cp "$BUILD_DIR/release/scry-mcp" "$APP_BUNDLE/Contents/MacOS/"

# Copy Info.plist
cp "$PROJECT_DIR/Sources/ScryApp/Info.plist" "$APP_BUNDLE/Contents/"

# Create PkgInfo
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

echo "Built: $APP_BUNDLE"
echo ""
echo "To run:"
echo "  open $APP_BUNDLE"
echo ""
echo "To install to Applications:"
echo "  cp -r $APP_BUNDLE /Applications/"
