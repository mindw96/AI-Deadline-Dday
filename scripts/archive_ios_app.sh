#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/Apps/Mobile/DdayMobile.xcodeproj"
SCHEME="DdayMobile"
CONFIGURATION="${CONFIGURATION:-Release}"
ARCHIVE_PATH="${ARCHIVE_PATH:-$ROOT_DIR/build/DdayMobile.xcarchive}"
ALLOW_PROVISIONING_UPDATES="${ALLOW_PROVISIONING_UPDATES:-1}"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Xcode project not found: $PROJECT_PATH" >&2
  exit 1
fi

mkdir -p "$(dirname "$ARCHIVE_PATH")"

XCODEBUILD_ARGS=(
  archive
  -project "$PROJECT_PATH"
  -scheme "$SCHEME"
  -configuration "$CONFIGURATION"
  -destination "generic/platform=iOS"
  -archivePath "$ARCHIVE_PATH"
)

if [[ "$ALLOW_PROVISIONING_UPDATES" == "1" ]]; then
  XCODEBUILD_ARGS+=(-allowProvisioningUpdates)
fi

if [[ -n "${DEVELOPMENT_TEAM:-}" ]]; then
  XCODEBUILD_ARGS+=(DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM")
fi

if [[ -n "${CODE_SIGN_IDENTITY:-}" ]]; then
  XCODEBUILD_ARGS+=(CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY")
fi

echo "Archiving $SCHEME..."
echo "Project: $PROJECT_PATH"
echo "Configuration: $CONFIGURATION"
echo "Archive: $ARCHIVE_PATH"
echo "Allow provisioning updates: $ALLOW_PROVISIONING_UPDATES"

if [[ -n "${DEVELOPMENT_TEAM:-}" ]]; then
  echo "Development team: configured"
fi

xcodebuild "${XCODEBUILD_ARGS[@]}"

echo "Archive created at $ARCHIVE_PATH"
