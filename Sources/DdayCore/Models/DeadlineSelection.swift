import Foundation

public struct DeadlineSelection: Codable, Equatable {
    public let conferenceID: String
    public let deadlineID: String

    public init(conferenceID: String, deadlineID: String) {
        self.conferenceID = conferenceID
        self.deadlineID = deadlineID
    }
}
