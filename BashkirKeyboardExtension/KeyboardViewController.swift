import UIKit
import SwiftUI

final class KeyboardViewController: UIInputViewController {
    private let layout = KeyboardLayout.russian
    private let alternativeCharacters = AlternativeCharactersProvider.default
    private lazy var hapticManager = HapticFeedbackManager()
    private lazy var inputHandler = KeyboardInputHandler(textDocumentProxy: textDocumentProxy,
                                                         haptics: hapticManager)
    private let longPressHandler = LongPressHandler()
    private var lastLayoutMode: KeyboardLayoutMode = .letters

    private var keyboardView: KeyboardView?
    private var currentTheme: KeyboardTheme = .system

    private var tokens: KeyboardThemeTokens {
        // Determine color scheme based on selected theme
        let scheme: ColorScheme
        switch currentTheme {
        case .system:
            // System theme follows device appearance
            scheme = traitCollection.userInterfaceStyle == .dark ? .dark : .light
        case .light:
            scheme = .light
        case .dark, .classic:
            scheme = .dark
        case .liquidGlass:
            // Liquid glass theme uses dark scheme
            scheme = .dark
        }
        return ThemeManager.tokens(for: currentTheme, colorScheme: scheme)
    }

    private var palette: UIKitThemePalette {
        ThemeBridge.palette(for: tokens)
    }

    private let defaults: UserDefaults = {
        // Always use App Group UserDefaults, never standard
        guard let appGroupDefaults = UserDefaults(suiteName: SharedAppGroup.identifier) else {
            // Fallback should never happen, but use standard if App Group fails
            return .standard
        }
        return appGroupDefaults
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        longPressHandler.containerView = view
        longPressHandler.haptics = hapticManager
        longPressHandler.onCharacterSelected = { [weak self] character in
            self?.textDocumentProxy.insertText(character)
        }
        observeThemeChanges()
        configureKeyboard()
        inputHandler.stateDidChange = { [weak self] state in
            self?.keyboardView?.update(state: state)
            self?.handleLayoutChangeIfNeeded(state.layoutMode)
            self?.reloadRows()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload theme every time keyboard appears
        reloadThemeAndUpdateUI()
    }
    
    private func reloadThemeAndUpdateUI() {
        loadThemeFromDefaults()
        longPressHandler.popupDelay = defaults.object(forKey: SharedSettingsKeys.popupDelay) as? Double ?? 0.2
        
        // Always update UI, even if theme didn't change (to ensure colors are correct)
        keyboardView?.updateTheme(palette)
        reloadRows()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Only update if system theme is selected and appearance changed
        if currentTheme == .system {
            guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
            keyboardView?.updateTheme(palette)
            reloadRows()
        }
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        inputHandler.updateProxy(textDocumentProxy)
    }

    private func configureKeyboard() {
        // Load theme BEFORE creating keyboard view
        loadThemeFromDefaults()
        
        // Force UserDefaults sync to get latest value
        defaults.synchronize()
        longPressHandler.popupDelay = defaults.object(forKey: SharedSettingsKeys.popupDelay) as? Double ?? 0.2
        
        let keyboardView = KeyboardView(palette: palette)
        keyboardView.delegate = self
        view.addSubview(keyboardView)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set keyboard height to 35% of screen height and keep above the system bar
        let screenHeight = UIScreen.main.bounds.height
        let keyboardHeight = screenHeight * 0.35
        let heightConstraint = keyboardView.heightAnchor.constraint(equalToConstant: keyboardHeight)
        
        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            heightConstraint,
            keyboardView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor)
        ])
        self.keyboardView = keyboardView
        reloadRows()
    }

    private func reloadRows() {
        guard let keyboardView else { return }
        loadThemeFromDefaults()
        keyboardView.updateTheme(palette)
        let rows = layout.rows(for: inputHandler.state.layoutMode)
        if inputHandler.state.layoutMode == .emoji {
            keyboardView.apply(rows: [layout.emojiBottomRow],
                               state: inputHandler.state,
                               palette: palette,
                               showingEmojiPanel: true,
                               emojiCharacters: emojiCharacters())
        } else {
            keyboardView.apply(rows: rows, state: inputHandler.state, palette: palette)
        }
    }

    private func loadThemeFromDefaults() {
        // Force synchronization before reading
        defaults.synchronize()
        
        if let rawValue = defaults.string(forKey: SharedSettingsKeys.selectedTheme),
           let theme = KeyboardTheme(rawValue: rawValue) {
            currentTheme = theme
        } else {
            // Default to system if no theme found
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
        // Theme changed in main app, reload and update
        loadThemeFromDefaults()
        defaults.synchronize()
        longPressHandler.popupDelay = defaults.object(forKey: SharedSettingsKeys.popupDelay) as? Double ?? 0.2
        keyboardView?.updateTheme(palette)
        reloadRows()
    }
    
    private func handleLayoutChangeIfNeeded(_ mode: KeyboardLayoutMode) {
        if mode != lastLayoutMode {
            keyboardView?.triggerSpaceHint(duration: 1.0)
            lastLayoutMode = mode
        }
    }
    
    private func emojiCharacters() -> [String] {
        return ["😀", "😁", "😂", "🤣", "😊", "😍", "😘", "😎", "🤩", "😇", "🤔", "😴"]
    }
}

extension KeyboardViewController: KeyboardViewDelegate {
    func keyboardView(_ view: KeyboardView, didTap key: KeyboardKey) {
        switch key.kind {
        case .nextKeyboard:
            advanceToNextInputMode()
        case .emoji:
            inputHandler.handle(key: key)
        default:
            inputHandler.handle(key: key)
        }
    }

    func keyboardView(_ view: KeyboardView,
                      didLongPress key: KeyboardKey,
                      from keyView: KeyView,
                      gesture: UILongPressGestureRecognizer) {
        // Handle long press for alternative characters
        guard let base = key.baseValue else { return }
        let alternatives = alternativeCharacters.alternatives(for: base)
        longPressHandler.handle(gesture: gesture,
                                keyView: keyView,
                                baseValue: base,
                                alternatives: alternatives,
                                isUppercase: inputHandler.state.isUppercase,
                                palette: palette)
    }
}
