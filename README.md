# Dday

`Dday` is a lightweight macOS menu bar app for tracking academic conference deadlines.

The first version is focused on one simple workflow:

1. Load a curated conference deadline list from local JSON.
2. Let the user choose a conference deadline from the menu bar menu.
3. Show the selected deadline as `D-42`, `D-Day`, or `D+3` in the macOS menu bar.

The menu bar item also supports three visual styles:

- Plain Text
- Light Badge
- Korean and English menu labels

## Current Status

This repository is in early MVP development.

- Platform: macOS
- Language: Swift
- UI: AppKit menu bar app
- Data: bundled JSON
- License: TBD

## Build

```bash
swift build
```

## Check

```bash
swift run DdayCoreChecks
```

The current Command Line Tools setup on this machine does not expose `XCTest`, so the first local verification target is a lightweight Swift executable check runner.

## Build a Local `.app`

```bash
./scripts/build_app.sh
```

The script creates:

```text
build/Dday.app
```

## Release

Releases are automated with GitHub Actions. Create and push a version tag to build
`Dday.app`, package it as a zip, and publish a GitHub Release:

```bash
git tag v0.1.1
git push origin v0.1.1
```

The release workflow also uploads a SHA-256 checksum file. If a tag already
exists, run the `Release` workflow manually from GitHub Actions and enter that
tag name.

## Data

The app currently ships with a small seed dataset in:

```text
Sources/DdayApp/Resources/conferences.json
```

The public contribution-oriented copy lives in:

```text
data/conferences.json
```

Every conference entry must include a source URL and the date when the source was checked.

## Menu Bar Options

Open the menu bar item and use:

- `Menu Bar Display` to choose whether the conference name is shown.
- `Visual Style` to switch between plain text and a light rounded badge.
- `Language` to use the system language, English, or Korean.
- `Machine Learning`, `Computer Vision`, `NLP`, and `General AI` to browse conferences by subcategory.
- `Add Custom D-Day...` to add a deadline that is not in the built-in conference list.
- `Check Conference List Updates` to manually fetch the latest conference list from GitHub.

The D-Day count is calculated in the user's local timezone. The menu shows both the source deadline, such as `2026-07-28 23:59 AoE`, and the converted local time.
Conferences whose deadlines have all passed remain selectable from `Past Conferences`, but are hidden from the main conference list.

When an update succeeds, the downloaded conference list is cached locally in Application Support and used on the next launch. If the update fails, the app keeps using the last cached list or the bundled list.

## Privacy

The initial version does not collect analytics, require accounts, or send user settings to a server. Settings are stored locally with `UserDefaults`.
