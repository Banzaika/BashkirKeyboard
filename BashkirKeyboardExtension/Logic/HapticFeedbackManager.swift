import UIKit

final class HapticFeedbackManager {
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    private(set) var isEnabled: Bool

    init(defaults: UserDefaults = UserDefaults(suiteName: SharedAppGroup.identifier) ?? .standard) {
        self.isEnabled = defaults.object(forKey: SharedSettingsKeys.hapticsEnabled) as? Bool ?? true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(defaultsDidChange),
                                               name: UserDefaults.didChangeNotification,
                                               object: defaults)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func playTapIfNeeded() {
        guard isEnabled else { return }
        if feedbackGenerator == nil {
            feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        }
        feedbackGenerator?.impactOccurred()
    }
    
    func playSelectionChanged() {
        guard isEnabled else { return }
        if feedbackGenerator == nil {
            feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        }
        feedbackGenerator?.impactOccurred(intensity: 0.5)
    }

    @objc private func defaultsDidChange(_ notification: Notification) {
        guard let defaults = notification.object as? UserDefaults else { return }
        self.isEnabled = defaults.object(forKey: SharedSettingsKeys.hapticsEnabled) as? Bool ?? isEnabled
    }
}
