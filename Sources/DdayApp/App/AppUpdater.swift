import AppKit
import Foundation
import Sparkle

@MainActor
final class AppUpdater {
    private let updaterController: SPUStandardUpdaterController

    init() {
        self.updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    func menuItem(title: String) -> NSMenuItem {
        let item = NSMenuItem(
            title: title,
            action: #selector(SPUStandardUpdaterController.checkForUpdates(_:)),
            keyEquivalent: ""
        )
        item.target = updaterController
        item.isEnabled = updaterController.updater.canCheckForUpdates
        return item
    }
}
