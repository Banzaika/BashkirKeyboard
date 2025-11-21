import UIKit

struct KeyboardState {
    var isShiftEnabled: Bool = false
    var isCapsLocked: Bool = false
    var layoutMode: KeyboardLayoutMode = .letters

    var isUppercase: Bool { isShiftEnabled || isCapsLocked }
}

final class KeyboardInputHandler {
    private weak var textDocumentProxy: UITextDocumentProxy?
    private let haptics: HapticFeedbackManager
    private let settingsDefaults: UserDefaults

    var state: KeyboardState {
        didSet { stateDidChange?(state) }
    }

    var stateDidChange: ((KeyboardState) -> Void)?

    init(textDocumentProxy: UITextDocumentProxy?,
         haptics: HapticFeedbackManager,
         defaults: UserDefaults = UserDefaults(suiteName: SharedAppGroup.identifier) ?? .standard) {
        self.textDocumentProxy = textDocumentProxy
        self.haptics = haptics
        self.settingsDefaults = defaults
        let initialShift = true
        self.state = KeyboardState(isShiftEnabled: initialShift, isCapsLocked: false, layoutMode: .letters)
    }

    func updateProxy(_ proxy: UITextDocumentProxy?) {
        self.textDocumentProxy = proxy
    }

    func handle(key: KeyboardKey) {
        haptics.playTapIfNeeded()
        switch key.kind {
        case .character(let value):
            insertCharacter(value)
            if state.isShiftEnabled && !state.isCapsLocked {
                state.isShiftEnabled = false
            }
        case .backspace:
            textDocumentProxy?.deleteBackward()
        case .space:
            textDocumentProxy?.insertText(" ")
        case .returnKey:
            textDocumentProxy?.insertText("\n")
        case .shift:
            toggleShift()
        case .numbersToggle:
            state.layoutMode = .numbers
        case .lettersToggle:
            state.layoutMode = .letters
        case .symbolToggle:
            state.layoutMode = .symbols
        case .emoji:
            state.layoutMode = state.layoutMode == .emoji ? .letters : .emoji
        case .nextKeyboard:
            // handled by UIInputViewController directly
            break
        }
    }

    private func insertCharacter(_ value: String) {
        let text = state.isUppercase ? value.uppercased() : value.lowercased()
        textDocumentProxy?.insertText(text)
    }

    private func toggleShift() {
        if state.isShiftEnabled && state.isCapsLocked == false {
            state.isCapsLocked = true
        } else if state.isCapsLocked {
            state.isCapsLocked = false
            state.isShiftEnabled = false
        } else {
            state.isShiftEnabled.toggle()
        }
    }
}
