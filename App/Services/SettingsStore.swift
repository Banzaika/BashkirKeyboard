import Combine
import Foundation

final class SettingsStore: ObservableObject {
    private let defaults: UserDefaults

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: SharedSettingsKeys.hapticsEnabled) }
    }

    @Published var selectedTheme: KeyboardTheme {
        didSet { defaults.set(selectedTheme.rawValue, forKey: SharedSettingsKeys.selectedTheme) }
    }

    init(defaults: UserDefaults = UserDefaults(suiteName: SharedAppGroup.identifier) ?? .standard) {
        self.defaults = defaults
        self.hapticsEnabled = defaults.object(forKey: SharedSettingsKeys.hapticsEnabled) as? Bool ?? true
        if let rawValue = defaults.string(forKey: SharedSettingsKeys.selectedTheme),
           let theme = KeyboardTheme(rawValue: rawValue) {
            self.selectedTheme = theme
        } else {
            self.selectedTheme = .system
        }
    }
}
