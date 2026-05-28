#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <release-tag>" >&2
  exit 64
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="$1"
APP_DIR="$ROOT/build/Dday.app"
DIST_DIR="$ROOT/dist"
DMG_ROOT="$ROOT/build/dmg-root"

export COPYFILE_DISABLE=1

if [[ ! -d "$APP_DIR" ]]; then
  echo "Missing app bundle: $APP_DIR" >&2
  echo "Run ./scripts/build_app.sh first." >&2
  exit 66
fi

mkdir -p "$DIST_DIR"
rm -f "$DIST_DIR/Dday-${TAG}.zip" \
      "$DIST_DIR/Dday-${TAG}.zip.sha256" \
      "$DIST_DIR/Dday-${TAG}.dmg" \
      "$DIST_DIR/Dday-${TAG}.dmg.sha256"

ditto --norsrc -c -k --keepParent "$APP_DIR" "$DIST_DIR/Dday-${TAG}.zip"

rm -rf "$DMG_ROOT"
mkdir -p "$DMG_ROOT"
ditto --norsrc "$APP_DIR" "$DMG_ROOT/Dday.app"
hdiutil create \
  -volname "Dday" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$DIST_DIR/Dday-${TAG}.dmg"

shasum -a 256 "$DIST_DIR/Dday-${TAG}.zip" > "$DIST_DIR/Dday-${TAG}.zip.sha256"
shasum -a 256 "$DIST_DIR/Dday-${TAG}.dmg" > "$DIST_DIR/Dday-${TAG}.dmg.sha256"
