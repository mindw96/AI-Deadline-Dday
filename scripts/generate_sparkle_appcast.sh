#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <release-tag>" >&2
  exit 64
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="$1"
DIST_DIR="$ROOT/dist"
DMG_PATH="$DIST_DIR/Dday-${TAG}.dmg"
APPCAST_SOURCE_DIR="$ROOT/build/sparkle-appcast-${TAG}"
APPCAST_PATH="$DIST_DIR/appcast.xml"
SPARKLE_ACCOUNT="${SPARKLE_KEY_ACCOUNT:-dev.mindw.Dday}"
DOWNLOAD_URL_PREFIX="${SPARKLE_DOWNLOAD_URL_PREFIX:-https://github.com/mindw96/AI-Conference-Dday/releases/download/${TAG}/}"
GENERATE_APPCAST="$ROOT/.build/artifacts/sparkle/Sparkle/bin/generate_appcast"

if [[ ! -x "$GENERATE_APPCAST" ]]; then
  echo "Missing Sparkle generate_appcast tool. Run swift package resolve first." >&2
  exit 66
fi

if [[ ! -f "$DMG_PATH" ]]; then
  echo "Missing DMG artifact: $DMG_PATH" >&2
  echo "Run ./scripts/notarize_release.sh $TAG first." >&2
  exit 66
fi

rm -rf "$APPCAST_SOURCE_DIR"
mkdir -p "$APPCAST_SOURCE_DIR"
cp "$DMG_PATH" "$APPCAST_SOURCE_DIR/"

RELEASE_NOTES_FILE="${SPARKLE_RELEASE_NOTES_FILE:-}"
if [[ -n "$RELEASE_NOTES_FILE" ]]; then
  cp "$RELEASE_NOTES_FILE" "$APPCAST_SOURCE_DIR/Dday-${TAG}.md"
else
  printf "# Dday %s\n\n- macOS update release.\n" "$TAG" > "$APPCAST_SOURCE_DIR/Dday-${TAG}.md"
fi

"$GENERATE_APPCAST" \
  --account "$SPARKLE_ACCOUNT" \
  --download-url-prefix "$DOWNLOAD_URL_PREFIX" \
  --maximum-versions 1 \
  --embed-release-notes \
  -o "$APPCAST_PATH" \
  "$APPCAST_SOURCE_DIR"

echo "Generated Sparkle appcast:"
echo "  $APPCAST_PATH"
