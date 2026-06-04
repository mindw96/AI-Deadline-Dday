#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/Apps/Mobile/DdayMobile.xcodeproj"
SCHEME="DdayMobile"
CONFIGURATION="${CONFIGURATION:-Release}"
ARCHIVE_PATH="${ARCHIVE_PATH:-$ROOT_DIR/build/DdayMobile.xcarchive}"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Xcode project not found: $PROJECT_PATH" >&2
  exit 1
fi

mkdir -p "$(dirname "$ARCHIVE_PATH")"

echo "Archiving $SCHEME..."
echo "Project: $PROJECT_PATH"
echo "Configuration: $CONFIGURATION"
echo "Archive: $ARCHIVE_PATH"

xcodebuild archive \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH"

echo "Archive created at $ARCHIVE_PATH"
