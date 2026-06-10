# Menu Bar D-Day for macOS

[한국어](MENUBAR_DDAY.ko.md) · [Main README](../README.md)

The macOS app shows a selected conference deadline directly in the menu bar.
It is designed for researchers who want one deadline to stay visible without
opening a full calendar app.

<p align="center">
  <img src="assets/menubar-preview.png" alt="Dday menu bar badge showing AAAI D-62" width="320">
</p>

## What It Does

- Shows the selected conference as `AAAI D-42`, `D-Day`, `H-10`, `M-59`, or `D+3`.
- Converts AoE and other source timezones into the user's local timezone.
- Lets the user choose whether to show the conference name in the menu bar.
- Supports plain text and badge-style menu bar appearances.
- Includes Korean, English, and system-language modes.
- Groups conferences by Machine Learning, Computer Vision, NLP, and General AI.
- Keeps passed conferences in a Past Conferences section instead of deleting them.
- Supports custom D-Days for personal deadlines.
- Can manually fetch the latest public conference list from GitHub.
- Includes Sparkle-based update checking for GitHub macOS releases.

## Install

1. Download the latest DMG from
   [GitHub Releases](https://github.com/mindw96/AI-Conference-Dday/releases/latest).
2. Open the DMG.
3. Drag `Dday.app` to `Applications`.
4. Launch `Dday.app`.

Current public macOS builds are Developer ID signed and notarized.

## Local Build

```bash
swift build
./scripts/build_app.sh
open build/Dday.app
```

## Release Build

Developer ID distribution uses:

```bash
./scripts/notarize_release.sh v1.1.1
```

The release script creates:

```text
dist/Dday-vX.Y.Z.dmg
dist/Dday-vX.Y.Z.zip
dist/appcast.xml
```

`appcast.xml` is uploaded with each GitHub Release so the macOS app can check
for updates from future versions.

## Data

The bundled macOS app includes a conference list, and can cache an updated list
after the user chooses manual update. If updating fails, it keeps using the last
cached list or the bundled list.

## Privacy

The macOS app stores settings locally with `UserDefaults`. It does not require
accounts, analytics, or tracking.
