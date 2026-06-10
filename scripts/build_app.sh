#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT/build/Dday.app"
SIGN_IDENTITY="${MACOS_SIGN_IDENTITY:-${SIGN_IDENTITY:-}}"
APP_VERSION="${APP_VERSION:-}"
APP_BUILD_VERSION="${APP_BUILD_VERSION:-}"

version_to_build_number() {
  local version="${1%%-*}"
  local major minor patch rest
  IFS='.' read -r major minor patch rest <<< "$version"
  major="${major:-0}"
  minor="${minor:-0}"
  patch="${patch:-0}"

  if [[ "$major" =~ ^[0-9]+$ && "$minor" =~ ^[0-9]+$ && "$patch" =~ ^[0-9]+$ ]]; then
    printf "%d" $((10#$major * 10000 + 10#$minor * 100 + 10#$patch))
  else
    printf "%s" "$1"
  fi
}

if [[ -z "$APP_BUILD_VERSION" && -n "$APP_VERSION" ]]; then
  APP_BUILD_VERSION="$(version_to_build_number "$APP_VERSION")"
fi

cd "$ROOT"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"
mkdir -p "$APP_DIR/Contents/Frameworks"
cp "$ROOT/.build/release/Dday" "$APP_DIR/Contents/MacOS/Dday"
cp "$ROOT/Support/Info.plist" "$APP_DIR/Contents/Info.plist"
if [[ -n "$APP_VERSION" ]]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_VERSION" "$APP_DIR/Contents/Info.plist"
fi
if [[ -n "$APP_BUILD_VERSION" ]]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $APP_BUILD_VERSION" "$APP_DIR/Contents/Info.plist"
fi
cp "$ROOT/Support/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
cp "$ROOT/Sources/DdayApp/Resources/conferences.json" "$APP_DIR/Contents/Resources/conferences.json"
SPARKLE_FRAMEWORK="$(find "$ROOT/.build/artifacts" -path "*/Sparkle.framework" -type d -print -quit 2>/dev/null || true)"
if [[ -z "$SPARKLE_FRAMEWORK" ]]; then
  echo "Missing Sparkle.framework. Run swift package resolve and build again." >&2
  exit 66
fi
ditto "$SPARKLE_FRAMEWORK" "$APP_DIR/Contents/Frameworks/Sparkle.framework"
chmod +x "$APP_DIR/Contents/MacOS/Dday"

if [[ -n "$SIGN_IDENTITY" ]]; then
  codesign --force --deep --options runtime --timestamp --sign "$SIGN_IDENTITY" "$APP_DIR/Contents/Frameworks/Sparkle.framework"
  codesign --force --options runtime --timestamp --sign "$SIGN_IDENTITY" "$APP_DIR"
else
  codesign --force --deep --sign - "$APP_DIR/Contents/Frameworks/Sparkle.framework"
  codesign --force --sign - "$APP_DIR"
fi

echo "Built $APP_DIR"
