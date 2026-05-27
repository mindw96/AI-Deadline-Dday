import Foundation

public struct ConferenceStore: Sendable {
    public let conferences: [Conference]

    public init(conferences: [Conference]) {
        self.conferences = conferences
    }

    public static func load(from url: URL) throws -> ConferenceStore {
        let data = try Data(contentsOf: url)
        return try load(from: data)
    }

    public static func load(from data: Data) throws -> ConferenceStore {
        let decoder = JSONDecoder()
        let conferences = try decoder.decode([Conference].self, from: data)
        return ConferenceStore(conferences: conferences.sorted())
    }

    public func conference(id: String) -> Conference? {
        conferences.first { $0.id == id }
    }

    public func deadline(selection: DeadlineSelection) -> (Conference, ConferenceDeadline)? {
        guard let conference = conference(id: selection.conferenceID),
              let deadline = conference.deadline(id: selection.deadlineID) else {
            return nil
        }

        return (conference, deadline)
    }
}

private extension Array where Element == Conference {
    func sorted() -> [Conference] {
        sorted {
            if $0.year == $1.year {
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }

            return $0.year < $1.year
        }
    }
}
