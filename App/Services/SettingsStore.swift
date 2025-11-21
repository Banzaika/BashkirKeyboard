import Combine
import Foundation

final class SettingsStore: ObservableObject {
    private let defaults: UserDefaults

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: SharedSettingsKeys.hapticsEnabled) }
    }
    
    @Published var popupDelay: Double {
        didSet {
            defaults.set(popupDelay, forKey: SharedSettingsKeys.popupDelay)
            defaults.synchronize()
        }
    }

    @Published var selectedTheme: KeyboardTheme {
        didSet {
            defaults.set(selectedTheme.rawValue, forKey: SharedSettingsKeys.selectedTheme)
            // Force synchronization to ensure keyboard extension sees the change
            defaults.synchronize()
        }
    }

    init(defaults: UserDefaults = UserDefaults(suiteName: SharedAppGroup.identifier) ?? .standard) {
        self.defaults = defaults
        self.hapticsEnabled = defaults.object(forKey: SharedSettingsKeys.hapticsEnabled) as? Bool ?? true
        self.popupDelay = defaults.object(forKey: SharedSettingsKeys.popupDelay) as? Double ?? 0.2
        if let rawValue = defaults.string(forKey: SharedSettingsKeys.selectedTheme),
           let theme = KeyboardTheme(rawValue: rawValue) {
            self.selectedTheme = theme
        } else {
            self.selectedTheme = .system
        }
    }
}
