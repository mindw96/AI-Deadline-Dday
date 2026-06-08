# App Store Submission Checklist

작성일: 2026-06-09
목표: 이번 주 안에 `Dday` iPhone/iPad 앱을 App Store 심사에 제출합니다.

이 문서는 기능 개발 체크리스트가 아니라 출시 운영 체크리스트입니다. 새 기능은 최대한 잠그고, 심사 통과와 공개 저장소 완성도를 우선합니다.

## Official References

- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Submit an app](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app)
- [Overview of submitting for review](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/overview-of-submitting-for-review/)
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/)

## Release Scope

### In Scope for First App Store Submission

- iPhone/iPad app
- Conference deadline browser
- Machine Learning, Computer Vision, NLP, General AI categories
- User-selected main D-Day
- Custom user D-Day
- Home screen Small and Medium widgets
- Lock Screen widgets
- Local deadline notifications
- Korean and English UI
- Widget background and text color settings
- Manual conference list update check

### Out of Scope for First App Store Submission

- watchOS app
- Account login
- Analytics
- Cloud sync
- Paid features
- Mac App Store release
- Fully transparent Home Screen widget background

## Current Technical Status

- [x] Apple Developer Program account is active.
- [x] Xcode is installed and selected.
- [x] iPhone/iPad app project exists at `Apps/Mobile/DdayMobile.xcodeproj`.
- [x] App target bundle ID is `dev.mindw.DdayMobile`.
- [x] Widget target bundle ID is `dev.mindw.DdayMobile.DdayWidgets`.
- [x] App Group is `group.dev.mindw.Dday`.
- [x] iPhone Simulator launch has been confirmed.
- [x] Real iPhone launch has been confirmed after signing setup.
- [x] Home Screen widgets are implemented.
- [x] Lock Screen widgets are implemented.
- [x] Local notifications are implemented.
- [x] App Store export scripts exist.
- [ ] App Store Connect app record is created and fully filled.
- [ ] TestFlight internal build is uploaded and processed.
- [ ] Final App Store review build is selected.

## Submission Blockers

These must be resolved before pressing Submit for Review.

- [ ] Decide whether first public App Store version should be `1.0.0` instead of current `0.1.0`.
- [ ] Confirm app icon is final in the Xcode asset catalog for all required sizes.
- [ ] Prepare App Store screenshots for required iPhone and iPad display sizes.
- [ ] Prepare a public privacy policy URL.
- [ ] Update `docs/PRIVACY.md` to mention manual public conference-list updates from GitHub.
- [ ] Add or confirm an in-app privacy/support path if needed for review clarity.
- [ ] Update README so the public repo describes iPhone/iPad widgets, not only the macOS menu bar app.
- [ ] Choose and add an open-source license before public promotion.
- [ ] Verify there is no committed Team ID, certificate name, provisioning profile, private key, `.p8`, or `.p12`.
- [ ] Verify App Store metadata has no placeholder text or dead URLs.

## App Store Connect Metadata

- [ ] App name: `Dday`
- [ ] Subtitle: decide final text, likely `AI Conference Deadlines`
- [ ] Primary category: decide between `Productivity` and `Education`
- [ ] Age rating completed
- [ ] Price: free
- [ ] Availability countries/regions selected
- [ ] Description written
- [ ] Keywords written
- [ ] Support URL prepared
- [ ] Privacy Policy URL prepared
- [ ] Marketing URL prepared or intentionally omitted
- [ ] Copyright owner text prepared
- [ ] Review notes written
- [ ] Reviewer contact info filled

## Suggested App Description Draft

```text
Dday helps AI researchers track important conference deadlines across Machine Learning, Computer Vision, NLP, and general AI venues.

Choose a main deadline, view it in the app, and keep it visible through Home Screen and Lock Screen widgets. Dday converts AoE conference deadlines into your local timezone and supports custom D-Days for events that are not in the built-in list.

The app works without accounts, analytics, or tracking. Conference data is bundled with the app and can be manually refreshed from the public project data source.
```

## Suggested Review Notes Draft

```text
Dday is a local-first academic conference deadline tracker for iPhone and iPad.

No login is required. The reviewer can open the app, choose a conference deadline as the main D-Day, add the Home Screen widget, and enable local notifications from Settings.

The app does not collect analytics, does not include ads, and does not require an account. Manual conference-list updates fetch public JSON data only; user settings and custom D-Days remain local on device.
```

## Privacy and Data

- [x] No account required.
- [x] No advertising SDK.
- [x] No analytics SDK.
- [x] No tracking.
- [x] User settings are stored locally.
- [x] Custom D-Days are stored locally.
- [ ] Confirm App Privacy answers match actual app behavior.
- [ ] Confirm whether manual GitHub data update changes any App Privacy answer.
- [ ] Publish privacy policy URL.
- [ ] Ensure privacy policy and App Store privacy answers say the same thing.

## Functional QA

Run this against the build intended for TestFlight or App Review.

- [ ] Fresh install launches without crash.
- [ ] Korean UI works.
- [ ] English UI works.
- [ ] System language mode works.
- [ ] Conference category selection updates Home.
- [ ] Conference detail opens.
- [ ] User can set a main D-Day from a conference deadline.
- [ ] Home shows selected main D-Day, not simply the nearest deadline.
- [ ] User can add a custom D-Day.
- [ ] User can remove a custom D-Day.
- [ ] Manual conference-list update succeeds or fails gracefully.
- [ ] AoE deadlines display in local timezone.
- [ ] D-Day, H-xx, and M-xx display modes work near deadline day.
- [ ] Past conferences do not clutter the main list.
- [ ] Empty main D-Day state is understandable.
- [ ] Settings screen is readable in light mode.
- [ ] Settings screen is readable in dark mode.

## Widget QA

- [ ] Small Home Screen widget shows selected main D-Day.
- [ ] Medium Home Screen widget shows selected main D-Day.
- [ ] Lock Screen inline widget shows selected main D-Day.
- [ ] Lock Screen rectangular widget shows selected main D-Day.
- [ ] Lock Screen circular widget shows selected main D-Day.
- [ ] Widget updates after changing main D-Day.
- [ ] Widget updates after changing background/text color settings.
- [ ] Widget has acceptable margins according to Apple HIG guidance.
- [ ] Widget text does not clip for long labels.
- [ ] Widget empty state is acceptable if no main D-Day is selected.

## Notification QA

- [ ] Notification permission prompt appears only when enabling reminders.
- [ ] Denied permission is handled gracefully.
- [ ] Enabled reminders schedule expected notifications.
- [ ] Scheduled reminder count is shown.
- [ ] Main D-Day notification items are included.
- [ ] Custom D-Day notification items are included.
- [ ] Past deadlines are not scheduled.
- [ ] Disabling reminders clears scheduled notifications.

## iPad QA

- [ ] iPad portrait layout is usable.
- [ ] iPad landscape layout is usable.
- [ ] Tab bar and navigation do not overlap content.
- [ ] Home card is not comically large on iPad.
- [ ] Conference list is readable on iPad.
- [ ] Settings screen is readable on iPad.

## Build and Upload

- [x] `xcodebuild` Simulator build succeeds.
- [ ] Archive succeeds in Xcode Organizer.
- [ ] Archive uses correct Team locally but does not commit Team ID.
- [ ] App Store Connect upload succeeds.
- [ ] Build processing completes.
- [ ] Internal TestFlight build installs.
- [ ] Internal TestFlight smoke test passes.
- [ ] App Review build selected.
- [ ] Submit for Review.

## Open Source Release

- [ ] README updated for the Apple-platform app.
- [ ] README keeps macOS menu bar status clear.
- [ ] Screenshots added for iPhone app, widget, and macOS menu bar.
- [ ] License chosen and committed.
- [ ] Contribution guide added or intentionally deferred.
- [ ] Data contribution guide verified.
- [ ] Public repo has no private signing details.
- [ ] GitHub topics and description updated.
- [ ] Release tag strategy decided.

## LinkedIn Launch Prep

- [ ] Decide whether to post at submission, TestFlight, approval, or App Store launch.
- [ ] Prepare one clean screenshot collage.
- [ ] Prepare GitHub link.
- [ ] Prepare App Store link after approval.
- [ ] Mention open source status.
- [ ] Mention target users: AI/ML/CV/NLP researchers.
- [ ] Avoid implying official affiliation with conferences.

## This Week Plan

### Day 1: Submission Checklist and Metadata

- [x] Create this checklist.
- [ ] Decide App Store version number.
- [ ] Draft App Store metadata.
- [ ] Prepare privacy/support URLs.

### Day 2: QA and Screenshots

- [ ] Run iPhone QA.
- [ ] Run iPad QA.
- [ ] Run Widget QA.
- [ ] Capture App Store screenshots.

### Day 3: TestFlight

- [ ] Archive.
- [ ] Upload to App Store Connect.
- [ ] Run internal TestFlight.
- [ ] Fix only release-blocking issues.

### Day 4: Public Repo Polish

- [ ] Update README.
- [ ] Add license.
- [ ] Add screenshots.
- [ ] Final sensitive-info scan.

### Day 5: App Review Submission

- [ ] Fill App Store Connect metadata.
- [ ] Attach screenshots.
- [ ] Complete App Privacy answers.
- [ ] Select final build.
- [ ] Submit for Review.

