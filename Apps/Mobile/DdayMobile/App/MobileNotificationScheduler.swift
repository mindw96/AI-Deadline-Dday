import DdayCore
import Foundation
import UserNotifications

struct MobileNotificationScheduleItem: Sendable {
    let id: String
    let title: String
    let deadlineText: String
    let deadlineLabel: String
    let deadlineDate: Date
}

@MainActor
struct MobileNotificationScheduler {
    private enum ReminderWindow: Int, CaseIterable {
        case sevenDays = 7
        case threeDays = 3
        case oneDay = 1
        case deadlineDay = 0

        var identifier: String {
            switch self {
            case .sevenDays:
                return "7d"
            case .threeDays:
                return "3d"
            case .oneDay:
                return "1d"
            case .deadlineDay:
                return "day"
            }
        }
    }

    private let center: UNUserNotificationCenter
    private let calendar: Calendar

    init(
        center: UNUserNotificationCenter = .current(),
        calendar: Calendar = .current
    ) {
        self.center = center
        self.calendar = calendar
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func notificationsAllowed() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    func clearScheduledReminders() async {
        let pendingRequests = await center.pendingNotificationRequests()
        let identifiers = pendingRequests
            .map(\.identifier)
            .filter { $0.hasPrefix("dday-reminder-") }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func schedule(
        items: [MobileNotificationScheduleItem],
        language: AppLanguage
    ) async throws -> Int {
        await clearScheduledReminders()

        var scheduledCount = 0
        for item in items {
            for window in ReminderWindow.allCases {
                guard let fireDate = reminderDate(for: item.deadlineDate, window: window),
                      fireDate > Date() else {
                    continue
                }

                let content = UNMutableNotificationContent()
                content.title = notificationTitle(for: item)
                content.body = notificationBody(for: item, window: window, language: language)
                content.sound = .default
                content.userInfo = [
                    "deadlineID": item.id,
                    "deadlineDate": item.deadlineDate.timeIntervalSince1970
                ]

                let components = calendar.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "dday-reminder-\(item.id)-\(window.identifier)",
                    content: content,
                    trigger: trigger
                )

                try await center.add(request)
                scheduledCount += 1
            }
        }

        return scheduledCount
    }

    private func reminderDate(for deadlineDate: Date, window: ReminderWindow) -> Date? {
        let deadlineDay = calendar.startOfDay(for: deadlineDate)
        guard let targetDay = calendar.date(byAdding: .day, value: -window.rawValue, to: deadlineDay) else {
            return nil
        }

        var components = calendar.dateComponents([.year, .month, .day], from: targetDay)
        components.hour = 9
        components.minute = 0

        guard let nineAM = calendar.date(from: components) else {
            return nil
        }

        if window == .deadlineDay && nineAM >= deadlineDate {
            return calendar.date(byAdding: .hour, value: -1, to: deadlineDate)
        }

        return nineAM
    }

    private func notificationTitle(for item: MobileNotificationScheduleItem) -> String {
        "\(item.title) \(item.deadlineText)"
    }

    private func notificationBody(
        for item: MobileNotificationScheduleItem,
        window: ReminderWindow,
        language: AppLanguage
    ) -> String {
        let korean = isKorean(language)

        switch window {
        case .sevenDays, .threeDays, .oneDay:
            if korean {
                return "\(item.deadlineLabel)까지 \(window.rawValue)일 남았습니다."
            }

            return "\(item.deadlineLabel) is in \(window.rawValue) day\(window.rawValue == 1 ? "" : "s")."
        case .deadlineDay:
            if korean {
                return "\(item.deadlineLabel) 당일입니다."
            }

            return "\(item.deadlineLabel) is today."
        }
    }

    private func isKorean(_ language: AppLanguage) -> Bool {
        switch language {
        case .korean:
            return true
        case .english:
            return false
        case .system:
            return Locale.preferredLanguages.first?.hasPrefix("ko") ?? false
        }
    }
}
