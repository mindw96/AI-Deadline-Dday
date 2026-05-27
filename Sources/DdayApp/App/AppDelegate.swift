import AppKit
import DdayCore
import Foundation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        do {
            guard let dataURL = Self.conferenceDataURL() else {
                throw AppError.missingBundledData
            }

            let conferenceDataUpdater = ConferenceDataUpdater()
            let store = try conferenceDataUpdater.loadPreferred(bundledURL: dataURL)
            menuBarController = MenuBarController(
                store: store,
                calculator: DeadlineCalculator(),
                settings: SettingsStore(),
                userDeadlineStore: UserDeadlineStore(),
                conferenceDataUpdater: conferenceDataUpdater
            )
        } catch {
            menuBarController = MenuBarController.fallback(error: error)
        }
    }

    private static func conferenceDataURL() -> URL? {
        if let appResourceURL = Bundle.main.resourceURL?.appendingPathComponent("conferences.json"),
           FileManager.default.fileExists(atPath: appResourceURL.path) {
            return appResourceURL
        }

        return Bundle.module.url(forResource: "conferences", withExtension: "json")
    }
}

private enum AppError: Error {
    case missingBundledData
}
