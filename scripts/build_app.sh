#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT/build/Dday.app"
SIGN_IDENTITY="${MACOS_SIGN_IDENTITY:-${SIGN_IDENTITY:-}}"
APP_VERSION="${APP_VERSION:-}"

cd "$ROOT"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"
cp "$ROOT/.build/release/Dday" "$APP_DIR/Contents/MacOS/Dday"
cp "$ROOT/Support/Info.plist" "$APP_DIR/Contents/Info.plist"
if [[ -n "$APP_VERSION" ]]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_VERSION" "$APP_DIR/Contents/Info.plist"
fi
cp "$ROOT/Support/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
cp "$ROOT/Sources/DdayApp/Resources/conferences.json" "$APP_DIR/Contents/Resources/conferences.json"
chmod +x "$APP_DIR/Contents/MacOS/Dday"

if [[ -n "$SIGN_IDENTITY" ]]; then
  codesign --force --options runtime --timestamp --sign "$SIGN_IDENTITY" "$APP_DIR"
else
  codesign --force --sign - "$APP_DIR"
fi

echo "Built $APP_DIR"
