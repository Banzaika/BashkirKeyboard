import Foundation

struct KeyboardKey: Identifiable, Hashable {
    enum Kind: Hashable {
        case character(String)
        case shift
        case backspace
        case space
        case returnKey
        case numbersToggle
        case lettersToggle
        case nextKeyboard
        case symbolToggle
    }

    let id = UUID()
    let kind: Kind

    var baseValue: String? {
        if case let .character(value) = kind {
            return value
        }
        return nil
    }

    func displayText(isUppercase: Bool) -> String {
        switch kind {
        case .character(let value):
            return isUppercase ? value.uppercased() : value
        case .shift:
            return "⇧"
        case .backspace:
            return "⌫"
        case .space:
            return ""
        case .returnKey:
            return "⏎"
        case .numbersToggle:
            return "123"
        case .lettersToggle:
            return "АБВ"
        case .symbolToggle:
            return "#+="
        case .nextKeyboard:
            return "🌐"
        }
    }

    var accessibilityLabel: String {
        switch kind {
        case .character(let value):
            return value
        case .shift:
            return "Shift"
        case .backspace:
            return "Backspace"
        case .space:
            return "Space"
        case .returnKey:
            return "Return"
        case .numbersToggle:
            return "Numbers"
        case .lettersToggle:
            return "Letters"
        case .symbolToggle:
            return "Symbols"
        case .nextKeyboard:
            return "Next Keyboard"
        }
    }
}
