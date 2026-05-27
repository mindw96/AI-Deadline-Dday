import DdayCore
import Foundation

enum DdayCoreChecks {
    static func run() throws {
        try checkFutureDeadlineUsesDMinusFormat()
        try checkSameLocalDeadlineDayUsesDDayFormat()
        try checkSameLocalDeadlineDayUsesHourCountdown()
        try checkSameLocalDeadlineDayUsesMinuteCountdown()
        try checkPastDeadlineUsesDPlusFormat()
        try checkAoEMapsToUTCMinusTwelve()
        try checkAoEDeadlineUsesLocalDisplayTimezone()
        try checkLoadsConferenceJSON()
        try checkLoadsConferenceJSONFromData()
        try checkConferenceDataUpdaterFallsBackWhenCacheIsInvalid()
        try checkLoadsProjectConferenceData()

        print("DdayCoreChecks passed")
    }

    private static func checkFutureDeadlineUsesDMinusFormat() throws {
        let deadline = ConferenceDeadline(
            id: "paper",
            label: "Paper Deadline",
            date: "2026-05-30",
            time: "23:59",
            timezone: "UTC",
            type: .submission,
            isPrimary: true
        )
        let now = try require(ISO8601DateFormatter().date(from: "2026-05-27T12:00:00Z"))

        let display = try DeadlineCalculator().display(
            for: deadline,
            now: now,
            displayTimeZone: TimeZone(secondsFromGMT: 0)!
        )

        try expect(display.text == "D-3", "expected D-3, got \(display.text)")
        try expect(display.days == 3, "expected 3 days, got \(display.days)")
    }

    private static func checkSameLocalDeadlineDayUsesDDayFormat() throws {
        let deadline = ConferenceDeadline(
            id: "paper",
            label: "Paper Deadline",
            date: "2026-05-27",
            time: "23:59",
            timezone: "UTC",
            type: .submission,
            isPrimary: true
        )
        let now = try require(ISO8601DateFormatter().date(from: "2026-05-27T12:00:00Z"))

        let display = try DeadlineCalculator().display(
            for: deadline,
            now: now,
            displayTimeZone: TimeZone(secondsFromGMT: 0)!
        )

        try expect(display.text == "H-12", "expected H-12, got \(display.text)")
        try expect(display.days == 0, "expected 0 days, got \(display.days)")
    }

    private static func checkSameLocalDeadlineDayUsesHourCountdown() throws {
        let deadline = ConferenceDeadline(
            id: "paper",
            label: "Paper Deadline",
            date: "2026-05-27",
            time: "23:59",
            timezone: "UTC",
            type: .submission,
            isPrimary: true
        )
        let timezone = TimeZone(secondsFromGMT: 0)!

        let h24Now = try require(ISO8601DateFormatter().date(from: "2026-05-27T00:00:00Z"))
        let h10Now = try require(ISO8601DateFormatter().date(from: "2026-05-27T14:00:00Z"))

        let h24Display = try DeadlineCalculator().display(
            for: deadline,
            now: h24Now,
            displayTimeZone: timezone
        )
        let h10Display = try DeadlineCalculator().display(
            for: deadline,
            now: h10Now,
            displayTimeZone: timezone
        )

        try expect(h24Display.text == "H-24", "expected H-24, got \(h24Display.text)")
        try expect(h10Display.text == "H-10", "expected H-10, got \(h10Display.text)")
    }

    private static func checkSameLocalDeadlineDayUsesMinuteCountdown() throws {
        let deadline = ConferenceDeadline(
            id: "paper",
            label: "Paper Deadline",
            date: "2026-05-27",
            time: "23:59",
            timezone: "UTC",
            type: .submission,
            isPrimary: true
        )
        let timezone = TimeZone(secondsFromGMT: 0)!

        let m59Now = try require(ISO8601DateFormatter().date(from: "2026-05-27T23:00:00Z"))
        let m10Now = try require(ISO8601DateFormatter().date(from: "2026-05-27T23:49:00Z"))
        let m1Now = try require(ISO8601DateFormatter().date(from: "2026-05-27T23:58:01Z"))

        let m59Display = try DeadlineCalculator().display(
            for: deadline,
            now: m59Now,
            displayTimeZone: timezone
        )
        let m10Display = try DeadlineCalculator().display(
            for: deadline,
            now: m10Now,
            displayTimeZone: timezone
        )
        let m1Display = try DeadlineCalculator().display(
            for: deadline,
            now: m1Now,
            displayTimeZone: timezone
        )

        try expect(m59Display.text == "M-59", "expected M-59, got \(m59Display.text)")
        try expect(m10Display.text == "M-10", "expected M-10, got \(m10Display.text)")
        try expect(m1Display.text == "M-1", "expected M-1, got \(m1Display.text)")
    }

    private static func checkPastDeadlineUsesDPlusFormat() throws {
        let deadline = ConferenceDeadline(
            id: "paper",
            label: "Paper Deadline",
            date: "2026-05-20",
            time: "23:59",
            timezone: "UTC",
            type: .submission,
            isPrimary: true
        )
        let now = try require(ISO8601DateFormatter().date(from: "2026-05-27T12:00:00Z"))

        let display = try DeadlineCalculator().display(
            for: deadline,
            now: now,
            displayTimeZone: TimeZone(secondsFromGMT: 0)!
        )

        try expect(display.text == "D+7", "expected D+7, got \(display.text)")
        try expect(display.days == -7, "expected -7 days, got \(display.days)")
    }

    private static func checkAoEMapsToUTCMinusTwelve() throws {
        let timezone = DeadlineCalculator().resolvedTimeZone("AoE")

        try expect(
            timezone.secondsFromGMT() == -12 * 60 * 60,
            "expected AoE to map to UTC-12"
        )
    }

    private static func checkAoEDeadlineUsesLocalDisplayTimezone() throws {
        let deadline = ConferenceDeadline(
            id: "full-paper",
            label: "Full Papers Due",
            date: "2026-07-28",
            time: "23:59",
            timezone: "AoE",
            type: .submission,
            isPrimary: true
        )
        let now = try require(ISO8601DateFormatter().date(from: "2026-07-28T00:00:00Z"))
        let korea = try require(TimeZone(identifier: "Asia/Seoul"))

        let display = try DeadlineCalculator().display(
            for: deadline,
            now: now,
            displayTimeZone: korea
        )

        try expect(display.text == "D-1", "expected D-1 in Asia/Seoul, got \(display.text)")
    }

    private static func checkLoadsConferenceJSON() throws {
        let url = try require(Bundle.module.url(forResource: "conferences-fixture", withExtension: "json"))
        let store = try ConferenceStore.load(from: url)

        try expect(store.conferences.count == 1, "expected one fixture conference")
        try expect(store.conferences.first?.id == "testconf-2026", "unexpected conference id")
        try expect(store.conferences.first?.subcategory == .ml, "unexpected fixture subcategory")
        try expect(store.conferences.first?.primaryDeadline?.id == "full-paper", "unexpected primary deadline")
    }

    private static func checkLoadsConferenceJSONFromData() throws {
        let url = try require(Bundle.module.url(forResource: "conferences-fixture", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let store = try ConferenceStore.load(from: data)

        try expect(store.conferences.count == 1, "expected one fixture conference from data")
        try expect(store.conferences.first?.id == "testconf-2026", "unexpected conference id from data")
    }

    private static func checkConferenceDataUpdaterFallsBackWhenCacheIsInvalid() throws {
        let fileManager = FileManager.default
        let fixtureURL = try require(Bundle.module.url(forResource: "conferences-fixture", withExtension: "json"))
        let temporaryDirectory = fileManager.temporaryDirectory
            .appendingPathComponent("DdayCoreChecks-\(UUID().uuidString)", isDirectory: true)
        let cacheURL = temporaryDirectory.appendingPathComponent("conferences.json")

        try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        defer {
            try? fileManager.removeItem(at: temporaryDirectory)
        }

        try Data("not json".utf8).write(to: cacheURL)

        let updater = ConferenceDataUpdater(
            remoteURL: URL(string: "https://example.invalid/conferences.json")!,
            cacheURL: cacheURL,
            fileManager: fileManager
        )
        let store = try updater.loadPreferred(bundledURL: fixtureURL)

        try expect(store.conferences.count == 1, "expected bundled data after invalid cache")
        try expect(!fileManager.fileExists(atPath: cacheURL.path), "invalid cache should be removed")
    }

    private static func checkLoadsProjectConferenceData() throws {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let url = root.appendingPathComponent("data/conferences.json")
        let store = try ConferenceStore.load(from: url)

        try expect(store.conferences.count >= 29, "expected at least 29 seed conferences")
        try expect(
            store.conferences.allSatisfy { !$0.deadlines.isEmpty },
            "each conference must have at least one deadline"
        )
        try expect(
            store.conferences.contains { $0.id == "eccv-2026" && $0.subcategory == .cv },
            "expected ECCV 2026 in CV subcategory"
        )
        try expect(
            store.conferences.contains { $0.id == "emnlp-2026" && $0.subcategory == .nlp },
            "expected EMNLP 2026 in NLP subcategory"
        )
        try expect(
            store.conferences.contains { $0.id == "neurips-2026" && $0.subcategory == .ml },
            "expected NeurIPS 2026 in ML subcategory"
        )
        try expect(
            store.conferences.contains { $0.id == "kdd-2026" && $0.subcategory == .ml },
            "expected KDD 2026 in ML subcategory"
        )
        try expect(
            store.conferences.contains { $0.id == "accv-2026" && $0.subcategory == .cv },
            "expected ACCV 2026 in CV subcategory"
        )
        try expect(
            store.conferences.contains { $0.id == "colm-2026" && $0.subcategory == .nlp },
            "expected COLM 2026 in NLP subcategory"
        )
        try expect(
            store.conferences.contains { $0.id == "sigir-2026" && $0.subcategory == .nlp },
            "expected SIGIR 2026 in NLP subcategory"
        )
        try expect(
            store.conferences.contains { $0.id == "ijcai-ecai-2026" && $0.subcategory == .generalAI },
            "expected IJCAI-ECAI 2026 in General AI subcategory"
        )
        try expect(
            store.conferences.contains { $0.id == "kr-2026" && $0.subcategory == .generalAI },
            "expected KR 2026 in General AI subcategory"
        )
    }

    private static func expect(
        _ condition: @autoclosure () -> Bool,
        _ message: String
    ) throws {
        if !condition() {
            throw CheckError(message)
        }
    }

    private static func require<T>(_ value: T?) throws -> T {
        guard let value else {
            throw CheckError("required value was nil")
        }

        return value
    }
}

private struct CheckError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}

try DdayCoreChecks.run()
