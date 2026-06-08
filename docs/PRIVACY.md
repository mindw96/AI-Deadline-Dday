# Privacy

Dday is local-first and does not collect personal data.

- No account is required.
- No analytics are collected.
- No advertising SDK is included.
- No tracking is used.
- User settings are stored locally with `UserDefaults`.
- Custom D-Days are stored locally on the device.
- Selected conference settings are stored locally on the device.

The app can manually fetch the latest public conference list from this project's
GitHub repository when the user chooses `Check Conference List Updates`. That
request downloads public JSON data only. Dday does not send custom D-Days,
selected deadlines, user settings, device identifiers, or account information as
part of that request.

Home Screen and Lock Screen widgets read the selected D-Day through the local
App Group container so the app and widget can share the same on-device data.
