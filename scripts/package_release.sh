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
RW_DMG="$ROOT/build/Dday-${TAG}-rw.dmg"
MOUNT_DIR="$ROOT/build/dmg-mount"
DMG_PATH="$DIST_DIR/Dday-${TAG}.dmg"
ZIP_PATH="$DIST_DIR/Dday-${TAG}.zip"
BACKGROUND_PATH="$DMG_ROOT/.background/dmg-background.png"

export COPYFILE_DISABLE=1

if [[ ! -d "$APP_DIR" ]]; then
  echo "Missing app bundle: $APP_DIR" >&2
  echo "Run ./scripts/build_app.sh first." >&2
  exit 66
fi

mkdir -p "$DIST_DIR"
rm -f "$ZIP_PATH" \
      "$ZIP_PATH.sha256" \
      "$DMG_PATH" \
      "$DMG_PATH.sha256" \
      "$RW_DMG"

ditto --norsrc -c -k --keepParent "$APP_DIR" "$ZIP_PATH"

rm -rf "$DMG_ROOT" "$MOUNT_DIR"
mkdir -p "$DMG_ROOT/.background" "$MOUNT_DIR"
ditto --norsrc "$APP_DIR" "$DMG_ROOT/Dday.app"
ln -s /Applications "$DMG_ROOT/Applications"
swift "$ROOT/scripts/generate_dmg_background.swift" "$BACKGROUND_PATH"
SetFile -a V "$DMG_ROOT/.background" || true

hdiutil create \
  -volname "Dday" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDRW \
  "$RW_DMG"

hdiutil attach "$RW_DMG" \
  -mountpoint "$MOUNT_DIR" \
  -nobrowse \
  -quiet

cleanup() {
  hdiutil detach "$MOUNT_DIR" -quiet || true
}
trap cleanup EXIT

sleep 1
osascript \
  -e "set dmgFolder to POSIX file \"$MOUNT_DIR\" as alias" \
  -e 'tell application "Finder" to open dmgFolder' >/dev/null
sleep 1
osascript \
  -e "set dmgFolder to POSIX file \"$MOUNT_DIR\" as alias" \
  -e 'tell application "Finder"' \
  -e 'set theWindow to container window of dmgFolder' \
  -e 'set current view of theWindow to icon view' \
  -e 'set toolbar visible of theWindow to false' \
  -e 'set statusbar visible of theWindow to false' \
  -e 'set bounds of theWindow to {100, 100, 860, 580}' \
  -e 'end tell' >/dev/null
osascript \
  -e "set dmgFolder to POSIX file \"$MOUNT_DIR\" as alias" \
  -e 'tell application "Finder"' \
  -e 'set theOptions to icon view options of container window of dmgFolder' \
  -e 'set arrangement of theOptions to not arranged' \
  -e 'set icon size of theOptions to 112' \
  -e 'set background picture of theOptions to file ".background:dmg-background.png" of dmgFolder' \
  -e 'set position of item "Dday.app" of dmgFolder to {190, 222}' \
  -e 'set position of item "Applications" of dmgFolder to {570, 222}' \
  -e 'end tell' >/dev/null
osascript \
  -e "set dmgFolder to POSIX file \"$MOUNT_DIR\" as alias" \
  -e 'tell application "Finder" to close container window of dmgFolder' >/dev/null || true

sync
hdiutil detach "$MOUNT_DIR" -quiet
trap - EXIT

hdiutil convert "$RW_DMG" \
  -format UDZO \
  -imagekey zlib-level=9 \
  -o "$DMG_PATH"

rm -f "$RW_DMG"

shasum -a 256 "$ZIP_PATH" > "$ZIP_PATH.sha256"
shasum -a 256 "$DMG_PATH" > "$DMG_PATH.sha256"
