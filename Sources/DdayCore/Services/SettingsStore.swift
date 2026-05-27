import Foundation

public final class SettingsStore {
    private enum Key {
        static let selectedConferenceID = "selectedConferenceID"
        static let selectedDeadlineID = "selectedDeadlineID"
        static let menuBarDisplayMode = "menuBarDisplayMode"
        static let menuBarVisualStyle = "menuBarVisualStyle"
        static let appLanguage = "appLanguage"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var selectedConferenceID: String? {
        get { defaults.string(forKey: Key.selectedConferenceID) }
        set { defaults.set(newValue, forKey: Key.selectedConferenceID) }
    }

    public var selectedDeadlineID: String? {
        get { defaults.string(forKey: Key.selectedDeadlineID) }
        set { defaults.set(newValue, forKey: Key.selectedDeadlineID) }
    }

    public var menuBarDisplayMode: MenuBarDisplayMode {
        get {
            guard let rawValue = defaults.string(forKey: Key.menuBarDisplayMode),
                  let mode = MenuBarDisplayMode(rawValue: rawValue) else {
                return .conferenceAndDday
            }

            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.menuBarDisplayMode)
        }
    }

    public var menuBarVisualStyle: MenuBarVisualStyle {
        get {
            guard let rawValue = defaults.string(forKey: Key.menuBarVisualStyle),
                  let style = MenuBarVisualStyle(rawValue: rawValue) else {
                return .plain
            }

            return style
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.menuBarVisualStyle)
        }
    }

    public var appLanguage: AppLanguage {
        get {
            guard let rawValue = defaults.string(forKey: Key.appLanguage),
                  let language = AppLanguage(rawValue: rawValue) else {
                return .system
            }

            return language
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.appLanguage)
        }
    }

    public var selectedDeadline: DeadlineSelection? {
        get {
            guard let selectedConferenceID,
                  let selectedDeadlineID else {
                return nil
            }

            return DeadlineSelection(
                conferenceID: selectedConferenceID,
                deadlineID: selectedDeadlineID
            )
        }
        set {
            selectedConferenceID = newValue?.conferenceID
            selectedDeadlineID = newValue?.deadlineID
        }
    }
}

public enum MenuBarDisplayMode: String, Codable, Equatable, CaseIterable {
    case ddayOnly
    case conferenceAndDday
    case conferenceAndDate
}

public enum MenuBarVisualStyle: String, Codable, Equatable, CaseIterable {
    case plain
    case badge
}

public enum AppLanguage: String, Codable, Equatable, CaseIterable {
    case system
    case english
    case korean
}
