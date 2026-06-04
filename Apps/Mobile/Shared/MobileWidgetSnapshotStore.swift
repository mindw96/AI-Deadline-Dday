import Foundation

enum DdayAppGroup {
    static let identifier = "group.dev.mindw.Dday"
}

struct MobileWidgetDeadlineSnapshot: Codable, Equatable, Sendable {
    let title: String
    let deadlineText: String
    let deadlineLabel: String
    let localDateText: String
    let sourceDateText: String
    let deadlineDate: Date
    let updatedAt: Date

    static let placeholder = MobileWidgetDeadlineSnapshot(
        title: "AAAI",
        deadlineText: "D-62",
        deadlineLabel: "Full Paper Deadline",
        localDateText: "Jul 28 at 11:59 PM",
        sourceDateText: "2026-07-28 23:59 AoE",
        deadlineDate: Date().addingTimeInterval(62 * 24 * 60 * 60),
        updatedAt: Date()
    )
}

struct MobileWidgetSnapshotStore {
    private enum Key {
        static let selectedDeadlineSnapshot = "selectedDeadlineSnapshot"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults? = UserDefaults(suiteName: DdayAppGroup.identifier)) {
        self.defaults = defaults ?? .standard
    }

    func save(_ snapshot: MobileWidgetDeadlineSnapshot) {
        guard let data = try? encoder.encode(snapshot) else {
            return
        }

        defaults.set(data, forKey: Key.selectedDeadlineSnapshot)
    }

    func load() -> MobileWidgetDeadlineSnapshot? {
        guard let data = defaults.data(forKey: Key.selectedDeadlineSnapshot) else {
            return nil
        }

        return try? decoder.decode(MobileWidgetDeadlineSnapshot.self, from: data)
    }
}
