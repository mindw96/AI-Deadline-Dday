# Widget D-Day for iPhone and iPad

[한국어](WIDGET_DDAY.ko.md) · [Main README](../README.md)

The iPhone and iPad app focuses on widgets. Pick the deadline that matters, and
Dday shows it on the Home Screen and Lock Screen.

<p align="center">
  <img src="assets/widget-home-preview.png" alt="Dday iPhone Home Screen widgets showing AAAI D-43" width="260">
  <img src="assets/widget-lock-preview.png" alt="Dday iPhone Lock Screen widgets showing AAAI D-43" width="260">
</p>

## What It Does

- Lets the user select a main D-Day from a conference detail screen.
- Shows the selected D-Day on the Home screen inside the app.
- Shares the selected deadline with WidgetKit through the App Group container.
- Supports Home Screen widgets:
  - Small
  - Medium
  - Large
  - Extra Large on iPad
- Supports Lock Screen widgets:
  - Circular
  - Rectangular
- Supports widget background and text color options.
- Supports custom D-Days for personal deadlines.
- Schedules local deadline reminders for the main D-Day and custom D-Days.
- Includes Korean, English, and system-language modes.

## User Flow

1. Open `Dday`.
2. Go to `Conferences`.
3. Choose a category and conference.
4. Pick the deadline you want to track.
5. Set it as the main D-Day.
6. Add a Dday widget to the Home Screen or Lock Screen.

The widget updates from the locally shared snapshot saved by the app.

## Widget Appearance

The app includes widget appearance settings:

- Background: System, White, Black, Navy
- Text color: Auto, Black, White

The System background follows the default iOS widget style. Custom colors are
applied to Home Screen widgets.

## Notifications

When deadline reminders are enabled, Dday schedules local notifications for the
main D-Day and custom D-Days:

- 7 days before
- 3 days before
- 1 day before
- deadline day

Dday does not use server push notifications.

## Local Build

Open the Xcode project:

```text
Apps/Mobile/DdayMobile.xcodeproj
```

Use the `DdayMobile` scheme for Simulator or device builds.

## Privacy

The mobile app and widget share data locally through the App Group container.
Custom D-Days, selected deadlines, widget appearance, and reminder settings stay
on the device.
