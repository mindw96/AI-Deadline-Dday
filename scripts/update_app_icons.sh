#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_ICON="$ROOT/image.png"
ICONSET_DIR="$ROOT/build/AppIcon.iconset"

if [[ ! -f "$SOURCE_ICON" ]]; then
  echo "Missing source icon: $SOURCE_ICON" >&2
  exit 66
fi

swift "$ROOT/scripts/render_app_icons.swift" \
  "$SOURCE_ICON" \
  "$ROOT/Support/AppIcon.png" \
  "$ROOT/Apps/Mobile/DdayMobile/Assets.xcassets/AppIcon.appiconset/AppIcon.png" \
  "$ICONSET_DIR"

iconutil -c icns "$ICONSET_DIR" -o "$ROOT/Support/AppIcon.icns"

echo "Updated app icons from $SOURCE_ICON"
echo "  $ROOT/Support/AppIcon.png"
echo "  $ROOT/Support/AppIcon.icns"
echo "  $ROOT/Apps/Mobile/DdayMobile/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
