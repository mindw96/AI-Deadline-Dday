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

#Preview {
    SettingsScreen()
        .environmentObject(MobileAppModel())
}
