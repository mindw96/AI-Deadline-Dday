# Release Guide

This guide tracks the public release flow for Dday.

## Local Development Build

```bash
./scripts/build_app.sh
```

This creates:

```text
build/Dday.app
```

For a release build, use `scripts/notarize_release.sh` instead of calling the
build script directly.

## Public Release Checklist

- Run `swift run DdayCoreChecks`.
- Build a Developer ID signed and notarized release.
- Confirm the app opens and appears in the macOS menu bar.
- Confirm bundled conference data loads.
- Confirm `Check for Dday Updates...` opens the Sparkle updater.
- Confirm `dist/appcast.xml` is generated for the release.
- Confirm each data entry has a source URL.
- Confirm `docs/PRIVACY.md` still matches the app behavior.

## Notarized GitHub Release

```bash
./scripts/notarize_release.sh v1.0.3
```

The script creates:

```text
dist/Dday-v1.0.3.dmg
dist/Dday-v1.0.3.dmg.sha256
dist/Dday-v1.0.3.zip
dist/Dday-v1.0.3.zip.sha256
dist/appcast.xml
```

Upload all five files to the GitHub Release. `appcast.xml` is used by Sparkle
automatic updates, and the DMG is the primary download for users.

## Sparkle Update Signing

Dday uses Sparkle for macOS automatic updates. The public update key is stored
in `Support/Info.plist`; the private key must stay in the local macOS Keychain
and must not be committed.

One-time key setup:

```bash
.build/artifacts/sparkle/Sparkle/bin/generate_keys --account dev.mindw.Dday
```

Print the existing public key:

```bash
.build/artifacts/sparkle/Sparkle/bin/generate_keys --account dev.mindw.Dday -p
```

Regenerate only the appcast for an already-built DMG:

```bash
./scripts/generate_sparkle_appcast.sh v1.0.3
```

Optional release notes:

```bash
SPARKLE_RELEASE_NOTES_FILE=private/release-notes/v1.0.3.md \
  ./scripts/generate_sparkle_appcast.sh v1.0.3
```
