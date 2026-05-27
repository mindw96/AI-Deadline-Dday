# Release Guide

This guide is a draft for future public releases.

## Local Release Build

```bash
./scripts/build_app.sh
```

This creates:

```text
build/Dday.app
```

## Public Release Checklist

- Run `swift run DdayCoreChecks`.
- Build `Dday.app`.
- Confirm the app opens and appears in the macOS menu bar.
- Confirm bundled conference data loads.
- Confirm each data entry has a source URL.
- Confirm `docs/PRIVACY.md` still matches the app behavior.
- Decide license before the first public repository release.

## Later

- Add Developer ID signing.
- Add notarization.
- Consider a `.dmg` release asset.
- Consider Homebrew Cask distribution.
