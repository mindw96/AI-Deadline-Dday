#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE_PATH="${ARCHIVE_PATH:-$ROOT_DIR/build/DdayMobile.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-$ROOT_DIR/build/AppStoreExport}"
EXPORT_OPTIONS_PLIST="${EXPORT_OPTIONS_PLIST:-$ROOT_DIR/Apps/Mobile/ExportOptions-AppStoreConnect.plist}"
ALLOW_PROVISIONING_UPDATES="${ALLOW_PROVISIONING_UPDATES:-1}"

if [[ ! -d "$ARCHIVE_PATH" ]]; then
  echo "Archive not found: $ARCHIVE_PATH" >&2
  echo "Run ./scripts/archive_ios_app.sh first." >&2
  exit 1
fi

if [[ ! -f "$EXPORT_OPTIONS_PLIST" ]]; then
  echo "Export options plist not found: $EXPORT_OPTIONS_PLIST" >&2
  exit 1
fi

XCODEBUILD_ARGS=(
  -exportArchive
  -archivePath "$ARCHIVE_PATH"
  -exportPath "$EXPORT_PATH"
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"
)

if [[ "$ALLOW_PROVISIONING_UPDATES" == "1" ]]; then
  XCODEBUILD_ARGS+=(-allowProvisioningUpdates)
fi

echo "Exporting App Store Connect package..."
echo "Archive: $ARCHIVE_PATH"
echo "Export path: $EXPORT_PATH"
echo "Export options: $EXPORT_OPTIONS_PLIST"
echo "Allow provisioning updates: $ALLOW_PROVISIONING_UPDATES"

xcodebuild "${XCODEBUILD_ARGS[@]}"

echo "Export completed at $EXPORT_PATH"
