import DdayCore
import Foundation

struct MobileConferenceLoader {
    private let updater = ConferenceDataUpdater()

    func loadBundledStore() throws -> ConferenceStore {
        guard let url = Bundle.main.url(forResource: "conferences", withExtension: "json") else {
            throw MobileConferenceLoaderError.missingBundledData
        }

        return try ConferenceStore.load(from: url)
    }

    func loadPreferredStore() throws -> ConferenceStore {
        guard let url = Bundle.main.url(forResource: "conferences", withExtension: "json") else {
            throw MobileConferenceLoaderError.missingBundledData
        }

        return try updater.loadPreferred(bundledURL: url)
    }

    func fetchLatestStore() async throws -> ConferenceStore {
        try await updater.fetchAndCacheLatest()
    }
}

enum MobileConferenceLoaderError: LocalizedError {
    case missingBundledData

    var errorDescription: String? {
        switch self {
        case .missingBundledData:
            return "Bundled conference data could not be found."
        }
    }
}
