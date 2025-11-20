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
        // Determine color scheme based on selected theme
        let scheme: ColorScheme
        switch currentTheme {
        case .system:
            // System theme follows device appearance
            scheme = traitCollection.userInterfaceStyle == .dark ? .dark : .light
        case .classic:
            // Classic theme is always dark
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
            self?.reloadRows()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        keyboardView?.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload theme every time keyboard appears
        reloadThemeAndUpdateUI()
    }
    
    private func reloadThemeAndUpdateUI() {
        let oldTheme = currentTheme
        loadThemeFromDefaults()
        
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
        
        let keyboardView = KeyboardView(palette: palette)
        keyboardView.delegate = self
        view.addSubview(keyboardView)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set keyboard height to 35% of screen height
        let screenHeight = UIScreen.main.bounds.height
        let keyboardHeight = screenHeight * 0.35
        
        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.heightAnchor.constraint(equalToConstant: keyboardHeight)
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
        keyboardView?.updateTheme(palette)
        reloadRows()
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
        // Handle long press on emoji key - switch keyboard
        if key.kind == .emoji && gesture.state == .began {
            advanceToNextInputMode()
            return
        }
        
        // Handle long press for alternative characters
        guard let base = key.baseValue else { return }
        let alternatives = alternativeCharacters.alternatives(for: base)
        longPressHandler.handle(gesture: gesture, keyView: keyView, alternatives: alternatives, palette: palette)
    }
}
