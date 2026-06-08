import DdayCore
import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var model: MobileAppModel

    var body: some View {
        NavigationStack {
            Form {
                Section(model.text.languageLabel) {
                    Picker(model.text.languageLabel, selection: $model.appLanguage) {
                        ForEach(AppLanguage.allCases, id: \.rawValue) { language in
                            Text(model.text.languageTitle(language)).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(model.text.data) {
                    Button {
                        Task {
                            await model.refreshConferenceData()
                        }
                    } label: {
                        HStack {
                            Text(model.text.checkConferenceListUpdates)
                            Spacer()
                            if model.isUpdatingData {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(model.isUpdatingData)

                    if let updateMessage = model.updateMessage {
                        Text(updateMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(model.text.widgetAppearance) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(model.text.widgetAppearanceDescription)
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 10) {
                            Text(model.text.widgetBackground)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            HStack(spacing: 10) {
                                ForEach(MobileWidgetBackground.allCases, id: \.rawValue) { background in
                                    WidgetColorSwatch(
                                        title: model.text.widgetBackgroundTitle(background),
                                        color: background.previewColor,
                                        foreground: background.swatchForeground,
                                        selected: model.widgetAppearance.background == background
                                    ) {
                                        model.setWidgetBackground(background)
                                    }
                                }
                            }
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 10) {
                            Text(model.text.widgetTextColor)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            HStack(spacing: 10) {
                                ForEach(MobileWidgetTextColor.allCases, id: \.rawValue) { textColor in
                                    WidgetColorSwatch(
                                        title: model.text.widgetTextColorTitle(textColor),
                                        color: textColor.previewColor,
                                        foreground: textColor.swatchForeground,
                                        selected: model.widgetAppearance.textColor == textColor
                                    ) {
                                        model.setWidgetTextColor(textColor)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section(model.text.notifications) {
                    Toggle(
                        model.text.enableNotifications,
                        isOn: Binding(
                            get: { model.notificationsEnabled },
                            set: { isEnabled in
                                Task {
                                    await model.setNotificationsEnabled(isEnabled)
                                }
                            }
                        )
                    )

                    Text(model.text.notificationDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if let notificationMessage = model.notificationMessage {
                        Text(notificationMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(model.text.privacy) {
                    Text(model.text.privacyBody)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(model.text.settingsTab)
        }
    }
}

private struct WidgetColorSwatch: View {
    let title: String
    let color: Color
    let foreground: Color
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color)
                        .frame(width: 54, height: 38)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(selected ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: selected ? 2 : 1)
                        )

                    if selected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(foreground)
                    }
                }

                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(width: 58)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private extension MobileWidgetBackground {
    var previewColor: Color {
        switch self {
        case .system:
            return Color(.systemGray5)
        case .white:
            return .white
        case .black:
            return .black
        case .navy:
            return Color(red: 0.07, green: 0.11, blue: 0.22)
        }
    }

    var swatchForeground: Color {
        switch self {
        case .black, .navy:
            return .white
        case .system, .white:
            return .black
        }
    }
}

private extension MobileWidgetTextColor {
    var previewColor: Color {
        switch self {
        case .automatic:
            return Color(.systemGray4)
        case .black:
            return .black
        case .white:
            return .white
        }
    }

    var swatchForeground: Color {
        switch self {
        case .black:
            return .white
        case .automatic, .white:
            return .black
        }
    }
}

#Preview {
    SettingsScreen()
        .environmentObject(MobileAppModel())
}
