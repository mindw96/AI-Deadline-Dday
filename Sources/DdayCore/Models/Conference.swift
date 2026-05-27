import Foundation

public struct Conference: Codable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let fullName: String
    public let year: Int
    public let field: [String]
    public let subcategory: ConferenceSubcategory
    public let location: String
    public let websiteUrl: URL
    public let sourceUrl: URL
    public let sourceCheckedAt: String
    public let timezone: String
    public let deadlines: [ConferenceDeadline]

    public init(
        id: String,
        name: String,
        fullName: String,
        year: Int,
        field: [String],
        subcategory: ConferenceSubcategory,
        location: String,
        websiteUrl: URL,
        sourceUrl: URL,
        sourceCheckedAt: String,
        timezone: String,
        deadlines: [ConferenceDeadline]
    ) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.year = year
        self.field = field
        self.subcategory = subcategory
        self.location = location
        self.websiteUrl = websiteUrl
        self.sourceUrl = sourceUrl
        self.sourceCheckedAt = sourceCheckedAt
        self.timezone = timezone
        self.deadlines = deadlines
    }
}

public enum ConferenceSubcategory: String, Codable, Equatable, CaseIterable, Sendable {
    case ml
    case cv
    case nlp
    case generalAI = "general-ai"
}

public extension Conference {
    var primaryDeadline: ConferenceDeadline? {
        deadlines.first(where: \.isPrimary) ?? deadlines.first
    }

    func deadline(id: String) -> ConferenceDeadline? {
        deadlines.first { $0.id == id }
    }
}
