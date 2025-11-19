import UIKit
import SwiftUI

final class KeyboardViewController: UIInputViewController {
    private let layout = KeyboardLayout.russian
    private let alternativeCharacters = AlternativeCharactersProvider.default
    private lazy var hapticManager = HapticFeedbackManager()
    private lazy var inputHandler = KeyboardInputHandler(textDocumentProxy: textDocumentProxy,
                                                         haptics: hapticManager)
    private let longPressHandler = LongPressHandler()

    private var keyboardView: KeyboardView?
    private var currentTheme: KeyboardTheme = .system

    private var tokens: KeyboardThemeTokens {
        let scheme: ColorScheme = traitCollection.userInterfaceStyle == .dark ? .dark : .light
        return ThemeManager.tokens(for: currentTheme, colorScheme: scheme)
    }

    private var palette: UIKitThemePalette {
        ThemeBridge.palette(for: tokens)
    }

    private let defaults = UserDefaults(suiteName: SharedAppGroup.identifier) ?? .standard

    override func viewDidLoad() {
        super.viewDidLoad()
        longPressHandler.containerView = view
        longPressHandler.onCharacterSelected = { [weak self] character in
            self?.textDocumentProxy.insertText(character)
        }
        observeThemeChanges()
        configureKeyboard()
        inputHandler.stateDidChange = { [weak self] state in
            self?.keyboardView?.update(state: state)
            self?.reloadRows()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        keyboardView?.frame = view.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        keyboardView?.updateTheme(palette)
        reloadRows()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        inputHandler.updateProxy(textDocumentProxy)
    }

    private func configureKeyboard() {
        loadThemeFromDefaults()
        let keyboardView = KeyboardView(palette: palette)
        keyboardView.delegate = self
        view.addSubview(keyboardView)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.keyboardView = keyboardView
        reloadRows()
    }

    private func reloadRows() {
        guard let keyboardView else { return }
        let rows = layout.rows(for: inputHandler.state.layoutMode)
        keyboardView.apply(rows: rows, state: inputHandler.state, palette: palette)
    }

    private func loadThemeFromDefaults() {
        if let rawValue = defaults.string(forKey: SharedSettingsKeys.selectedTheme),
           let theme = KeyboardTheme(rawValue: rawValue) {
            currentTheme = theme
        } else {
            currentTheme = .system
        }
    }

    private func observeThemeChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDefaultsChange),
                                               name: UserDefaults.didChangeNotification,
                                               object: defaults)
    }

    @objc private func handleDefaultsChange() {
        loadThemeFromDefaults()
        keyboardView?.updateTheme(palette)
    }
}

extension KeyboardViewController: KeyboardViewDelegate {
    func keyboardView(_ view: KeyboardView, didTap key: KeyboardKey) {
        switch key.kind {
        case .nextKeyboard:
            advanceToNextInputMode()
        default:
            inputHandler.handle(key: key)
        }
    }

    func keyboardView(_ view: KeyboardView,
                      didLongPress key: KeyboardKey,
                      from keyView: KeyView,
                      gesture: UILongPressGestureRecognizer) {
        guard let base = key.baseValue else { return }
        let alternatives = alternativeCharacters.alternatives(for: base)
        longPressHandler.handle(gesture: gesture, keyView: keyView, alternatives: alternatives, palette: palette)
    }
}
