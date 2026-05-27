# Data Guide

Conference data is stored as JSON so app releases and data updates can evolve separately.

## Required Rules

- Every conference must have a stable lowercase `id`.
- Every date must include an official `sourceUrl`.
- `sourceCheckedAt` must be updated whenever a human verifies the source.
- Do not copy long CFP text into the data file.
- Keep only factual schedule data: names, dates, timezones, locations, tags, and source links.

## Timezones

Use `AoE` for Anywhere on Earth deadlines. The app resolves `AoE` as UTC-12.

Use IANA timezone identifiers for local event dates:

- `Asia/Seoul`
- `America/Los_Angeles`
- `Australia/Sydney`

## Primary Deadline

Each conference should have one primary deadline where possible. For paper-driven conferences, this is normally the full paper submission deadline.

When all submission dates are in the past, the app can still show future notification or conference dates.
