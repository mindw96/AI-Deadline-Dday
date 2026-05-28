#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT/build/Dday.app"

cd "$ROOT"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"
cp "$ROOT/.build/release/Dday" "$APP_DIR/Contents/MacOS/Dday"
cp "$ROOT/Support/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$ROOT/Support/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
cp "$ROOT/Sources/DdayApp/Resources/conferences.json" "$APP_DIR/Contents/Resources/conferences.json"
chmod +x "$APP_DIR/Contents/MacOS/Dday"
codesign --force --deep --sign - "$APP_DIR"

echo "Built $APP_DIR"
