import Foundation

public struct UserDeadline: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let label: String
    public let date: String
    public let time: String?
    public let timezone: String
    public let createdAt: Date

    public init(
        id: String,
        name: String,
        label: String,
        date: String,
        time: String?,
        timezone: String,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.label = label
        self.date = date
        self.time = time
        self.timezone = timezone
        self.createdAt = createdAt
    }

    public var deadline: ConferenceDeadline {
        ConferenceDeadline(
            id: "deadline",
            label: label,
            date: date,
            time: time,
            timezone: timezone,
            type: .submission,
            isPrimary: true
        )
    }
}
