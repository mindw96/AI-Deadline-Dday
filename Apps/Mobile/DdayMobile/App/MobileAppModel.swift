import Combine
import DdayCore
import Foundation
import WidgetKit

@MainActor
final class MobileAppModel: ObservableObject {
    private enum Key {
        static let selectedSourceKind = "mobileSelectedSourceKind"
        static let selectedConferenceID = "mobileSelectedConferenceID"
        static let selectedDeadlineID = "mobileSelectedDeadlineID"
        static let selectedCustomDeadlineID = "mobileSelectedCustomDeadlineID"
        static let notificationsEnabled = "mobileNotificationsEnabled"
    }

    @Published private(set) var store: ConferenceStore?
    @Published private(set) var errorMessage: String?
    @Published var selectedSubcategory: ConferenceSubcategory = .ml
    @Published private(set) var userDeadlines: [UserDeadline] = []
    @Published private(set) var selectedSource: MobileDeadlineSource?
    @Published private(set) var isUpdatingData = false
    @Published private(set) var updateMessage: String?
    @Published private(set) var notificationsEnabled = false
    @Published private(set) var notificationMessage: String?
    @Published var appLanguage: AppLanguage {
        didSet {
            settingsStore.appLanguage = appLanguage
            Task {
                await refreshNotificationsIfNeeded()
            }
        }
    }

    private let loader: MobileConferenceLoader
    private let calculator = DeadlineCalculator()
    private let settingsStore: SettingsStore
    private let userDeadlineStore: UserDeadlineStore
    private let widgetSnapshotStore: MobileWidgetSnapshotStore
    private let notificationScheduler: MobileNotificationScheduler
    private let defaults: UserDefaults

    var text: MobileAppText {
        MobileAppText(language: appLanguage)
    }

    init(
        loader: MobileConferenceLoader = MobileConferenceLoader(),
        settingsStore: SettingsStore = SettingsStore(),
        userDeadlineStore: UserDeadlineStore = UserDeadlineStore(),
        widgetSnapshotStore: MobileWidgetSnapshotStore = MobileWidgetSnapshotStore(),
        notificationScheduler: MobileNotificationScheduler = MobileNotificationScheduler(),
        defaults: UserDefaults = .standard
    ) {
        self.loader = loader
        self.settingsStore = settingsStore
        self.userDeadlineStore = userDeadlineStore
        self.widgetSnapshotStore = widgetSnapshotStore
        self.notificationScheduler = notificationScheduler
        self.defaults = defaults
        appLanguage = settingsStore.appLanguage
        selectedSource = Self.loadSelectedSource(defaults: defaults)
        notificationsEnabled = defaults.bool(forKey: Key.notificationsEnabled)
        load()
        Task {
            await refreshNotificationsIfNeeded()
        }
    }

    func load() {
        do {
            store = try loader.loadPreferredStore()
            userDeadlines = userDeadlineStore.deadlines
            errorMessage = nil
            syncWidgetSnapshot()
        } catch {
            store = nil
            errorMessage = error.localizedDescription
        }
    }

    var featuredSummary: MobileDeadlineSummary? {
        selectedSummary ?? upcomingSummaries.first
    }

    var activeConferences: [Conference] {
        store?.conferences.filter { nextSummary(for: $0) != nil } ?? []
    }

    var upcomingSummaries: [MobileDeadlineSummary] {
        let conferenceSummaries = store?.conferences.flatMap(upcomingSummaries(for:)) ?? []
        return (conferenceSummaries + customDeadlineSummaries.filter { $0.display.remainingSeconds > 0 })
            .sorted { $0.display.deadlineDate < $1.display.deadlineDate }
    }

    var customDeadlineSummaries: [MobileDeadlineSummary] {
        userDeadlines
            .compactMap(summary(for:))
            .sorted { $0.display.deadlineDate < $1.display.deadlineDate }
    }

    var selectedSummary: MobileDeadlineSummary? {
        guard let selectedSource else {
            return nil
        }

        return summary(for: selectedSource)
    }

    func conferences(in subcategory: ConferenceSubcategory) -> [Conference] {
        activeConferences.filter { $0.subcategory == subcategory }
    }

    func pastConferences(in subcategory: ConferenceSubcategory) -> [Conference] {
        (store?.conferences ?? [])
            .filter { $0.subcategory == subcategory }
            .filter { nextSummary(for: $0) == nil }
    }

    func summary(for conference: Conference) -> MobileDeadlineSummary? {
        nextSummary(for: conference) ?? fallbackSummary(for: conference)
    }

    func summaries(for conference: Conference) -> [MobileDeadlineSummary] {
        conference.deadlines
            .compactMap { deadline in
                summary(for: conference, deadline: deadline)
            }
            .sorted { $0.display.deadlineDate < $1.display.deadlineDate }
    }

    func select(_ source: MobileDeadlineSource) {
        selectedSource = source
        saveSelectedSource(source)
        syncWidgetSnapshot(reload: true)
        Task {
            await refreshNotificationsIfNeeded()
        }
    }

    func isSelected(_ source: MobileDeadlineSource) -> Bool {
        selectedSource == source
    }

    func addCustomDeadline(
        name: String,
        label: String,
        date: Date,
        timezone: CustomDeadlineTimezone
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
        let deadline = UserDeadline(
            id: UUID().uuidString,
            name: trimmedName,
            label: trimmedLabel.isEmpty ? "Deadline" : trimmedLabel,
            date: Self.dateFormatter.string(from: date),
            time: Self.timeFormatter.string(from: date),
            timezone: timezone.deadlineTimezoneIdentifier,
            createdAt: Date()
        )

        userDeadlineStore.add(deadline)
        userDeadlines = userDeadlineStore.deadlines
        select(.custom(id: deadline.id))
    }

    func removeCustomDeadline(source: MobileDeadlineSource) {
        guard case .custom(let id) = source else {
            return
        }

        userDeadlineStore.remove(id: id)
        userDeadlines = userDeadlineStore.deadlines
        if selectedSource == source {
            selectedSource = nil
            clearSelectedSource()
        }
        syncWidgetSnapshot(reload: true)
        Task {
            await refreshNotificationsIfNeeded()
        }
    }

    func refreshConferenceData() async {
        isUpdatingData = true
        updateMessage = nil

        do {
            store = try await loader.fetchLatestStore()
            updateMessage = text.updateSucceeded
            syncWidgetSnapshot(reload: true)
            await refreshNotificationsIfNeeded()
        } catch {
            updateMessage = text.updateFailed(error.localizedDescription)
        }

        isUpdatingData = false
    }

    func display(for deadline: ConferenceDeadline) -> DeadlineDisplay? {
        try? calculator.display(for: deadline)
    }

    func setNotificationsEnabled(_ enabled: Bool) async {
        if enabled {
            let granted = await notificationScheduler.requestAuthorization()
            guard granted else {
                notificationsEnabled = false
                defaults.set(false, forKey: Key.notificationsEnabled)
                notificationMessage = text.notificationPermissionDenied
                await notificationScheduler.clearScheduledReminders()
                return
            }

            notificationsEnabled = true
            defaults.set(true, forKey: Key.notificationsEnabled)
            await refreshNotificationsIfNeeded()
        } else {
            notificationsEnabled = false
            defaults.set(false, forKey: Key.notificationsEnabled)
            notificationMessage = text.notificationsDisabled
            await notificationScheduler.clearScheduledReminders()
        }
    }

    func refreshNotificationsIfNeeded() async {
        guard notificationsEnabled else {
            return
        }

        guard await notificationScheduler.notificationsAllowed() else {
            notificationsEnabled = false
            defaults.set(false, forKey: Key.notificationsEnabled)
            notificationMessage = text.notificationPermissionDenied
            await notificationScheduler.clearScheduledReminders()
            return
        }

        let items = notificationScheduleItems()
        guard !items.isEmpty else {
            notificationMessage = text.noNotificationsToSchedule
            await notificationScheduler.clearScheduledReminders()
            return
        }

        do {
            let count = try await notificationScheduler.schedule(
                items: items,
                language: appLanguage
            )
            notificationMessage = text.notificationsScheduled(count)
        } catch {
            notificationMessage = text.notificationSchedulingFailed(error.localizedDescription)
        }
    }

    private func nextSummary(for conference: Conference) -> MobileDeadlineSummary? {
        upcomingSummaries(for: conference)
            .min { $0.display.deadlineDate < $1.display.deadlineDate }
    }

    private func fallbackSummary(for conference: Conference) -> MobileDeadlineSummary? {
        conference.deadlines
            .compactMap { summary(for: conference, deadline: $0) }
            .max { $0.display.deadlineDate < $1.display.deadlineDate }
    }

    private func upcomingSummaries(for conference: Conference) -> [MobileDeadlineSummary] {
        conference.deadlines
            .compactMap { summary(for: conference, deadline: $0) }
            .filter { $0.display.remainingSeconds > 0 }
    }

    private func summary(
        for conference: Conference,
        deadline: ConferenceDeadline
    ) -> MobileDeadlineSummary? {
        guard let display = try? calculator.display(for: deadline) else {
            return nil
        }

        return MobileDeadlineSummary(
            conference: conference,
            deadline: deadline,
            display: display
        )
    }

    private func summary(for userDeadline: UserDeadline) -> MobileDeadlineSummary? {
        guard let display = try? calculator.display(for: userDeadline.deadline) else {
            return nil
        }

        return MobileDeadlineSummary(
            userDeadline: userDeadline,
            display: display
        )
    }

    private func summary(for source: MobileDeadlineSource) -> MobileDeadlineSummary? {
        switch source {
        case .conference(let conferenceID, let deadlineID):
            guard let conference = store?.conference(id: conferenceID),
                  let deadline = conference.deadline(id: deadlineID) else {
                return nil
            }

            return summary(for: conference, deadline: deadline)
        case .custom(let id):
            guard let userDeadline = userDeadlines.first(where: { $0.id == id }) else {
                return nil
            }

            return summary(for: userDeadline)
        }
    }

    private func syncWidgetSnapshot(reload: Bool = false) {
        guard let summary = featuredSummary else {
            return
        }

        widgetSnapshotStore.save(
            MobileWidgetDeadlineSnapshot(
                title: summary.title,
                deadlineText: summary.display.text,
                deadlineLabel: summary.deadlineLabel,
                localDateText: summary.localDateText,
                sourceDateText: summary.sourceDateText,
                deadlineDate: summary.display.deadlineDate,
                updatedAt: Date()
            )
        )

        if reload {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func notificationScheduleItems() -> [MobileNotificationScheduleItem] {
        var seenIDs = Set<String>()
        let summaries = ([featuredSummary].compactMap { $0 } + customDeadlineSummaries)
            .filter { $0.display.remainingSeconds > 0 }

        return summaries.compactMap { summary in
            guard seenIDs.insert(summary.id).inserted else {
                return nil
            }

            return MobileNotificationScheduleItem(
                id: summary.id,
                title: summary.title,
                deadlineText: summary.display.text,
                deadlineLabel: summary.deadlineLabel,
                deadlineDate: summary.display.deadlineDate
            )
        }
    }

    private func saveSelectedSource(_ source: MobileDeadlineSource) {
        defaults.set(source.storageKind, forKey: Key.selectedSourceKind)
        switch source {
        case .conference(let conferenceID, let deadlineID):
            defaults.set(conferenceID, forKey: Key.selectedConferenceID)
            defaults.set(deadlineID, forKey: Key.selectedDeadlineID)
            defaults.removeObject(forKey: Key.selectedCustomDeadlineID)
        case .custom(let id):
            defaults.set(id, forKey: Key.selectedCustomDeadlineID)
            defaults.removeObject(forKey: Key.selectedConferenceID)
            defaults.removeObject(forKey: Key.selectedDeadlineID)
        }
    }

    private func clearSelectedSource() {
        defaults.removeObject(forKey: Key.selectedSourceKind)
        defaults.removeObject(forKey: Key.selectedConferenceID)
        defaults.removeObject(forKey: Key.selectedDeadlineID)
        defaults.removeObject(forKey: Key.selectedCustomDeadlineID)
    }

    private static func loadSelectedSource(defaults: UserDefaults) -> MobileDeadlineSource? {
        switch defaults.string(forKey: Key.selectedSourceKind) {
        case "conference":
            guard let conferenceID = defaults.string(forKey: Key.selectedConferenceID),
                  let deadlineID = defaults.string(forKey: Key.selectedDeadlineID) else {
                return nil
            }

            return .conference(conferenceID: conferenceID, deadlineID: deadlineID)
        case "custom":
            guard let id = defaults.string(forKey: Key.selectedCustomDeadlineID) else {
                return nil
            }

            return .custom(id: id)
        default:
            return nil
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
