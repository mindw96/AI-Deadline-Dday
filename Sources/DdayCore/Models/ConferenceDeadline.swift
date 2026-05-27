import Foundation

public struct ConferenceDeadline: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let label: String
    public let date: String
    public let time: String?
    public let timezone: String
    public let type: DeadlineKind
    public let isPrimary: Bool

    public init(
        id: String,
        label: String,
        date: String,
        time: String?,
        timezone: String,
        type: DeadlineKind,
        isPrimary: Bool
    ) {
        self.id = id
        self.label = label
        self.date = date
        self.time = time
        self.timezone = timezone
        self.type = type
        self.isPrimary = isPrimary
    }
}

public enum DeadlineKind: String, Codable, Equatable, Sendable {
    case abstract
    case submission
    case supplementary
    case notification
    case cameraReady = "camera-ready"
    case conferenceStart = "conference-start"
    case conferenceEnd = "conference-end"
}
