# macOS Signing and Notarization

This repository can build the macOS menu bar app locally, but public GitHub
distribution requires a Developer ID signed and notarized build.

App Store signing certificates are not enough for direct GitHub downloads. Use a
`Developer ID Application` certificate for the app distributed outside the Mac
App Store.

## One-time setup

1. Open Xcode.
2. Go to `Xcode > Settings > Accounts`.
3. Select the Apple Developer team.
4. Open `Manage Certificates`.
5. Create a `Developer ID Application` certificate.
6. Create a notarytool keychain profile:

```bash
xcrun notarytool store-credentials "DdayNotary" \
  --apple-id "YOUR_APPLE_ID_EMAIL" \
  --team-id "YOUR_TEAM_ID" \
  --password "YOUR_APP_SPECIFIC_PASSWORD"
```

Use an app-specific password from the Apple ID account page. Do not commit the
Apple ID, team ID, password, certificates, or exported private keys.

## Local notarized release

```bash
./scripts/notarize_release.sh v1.0.1
```

The script:

1. Builds `build/Dday.app`.
2. Signs it with `Developer ID Application` and hardened runtime.
3. Submits it to Apple notarization.
4. Staples the notarization ticket to the app.
5. Creates the zip and DMG release files.
6. Notarizes and staples the DMG.
7. Rewrites SHA-256 checksum files.

If the keychain profile uses a different name:

```bash
NOTARYTOOL_PROFILE="MyProfile" ./scripts/notarize_release.sh v1.0.1
```

If multiple Developer ID certificates are installed:

```bash
MACOS_SIGN_IDENTITY="Developer ID Application: Your Name" ./scripts/notarize_release.sh v1.0.1
```

## Validation

```bash
codesign --verify --deep --strict --verbose=2 build/Dday.app
spctl -a -vv build/Dday.app
xcrun stapler validate build/Dday.app
xcrun stapler validate dist/Dday-v1.0.1.dmg
```
