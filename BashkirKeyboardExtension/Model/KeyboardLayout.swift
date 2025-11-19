import Foundation

enum KeyboardLayoutMode {
    case letters
    case numbers
}

struct KeyboardLayout {
    let letterRows: [KeyboardRow]
    let numberRows: [KeyboardRow]

    func rows(for mode: KeyboardLayoutMode) -> [KeyboardRow] {
        switch mode {
        case .letters:
            return letterRows
        case .numbers:
            return numberRows
        }
    }

    static let russian = KeyboardLayout(
        letterRows: [
            KeyboardRow(keys: characters("йцукенгшщзхъ")),
            KeyboardRow(keys: characters("фывапролджэ")),
            KeyboardRow(keys: [KeyboardKey(kind: .shift)] + characters("ячсмитьбю.") + [KeyboardKey(kind: .backspace)]),
            KeyboardRow(keys: [
                KeyboardKey(kind: .numbersToggle),
                KeyboardKey(kind: .nextKeyboard),
                KeyboardKey(kind: .space),
                KeyboardKey(kind: .returnKey)
            ])
        ],
        numberRows: [
            KeyboardRow(keys: characters("1234567890")),
            KeyboardRow(keys: characters("-/:;()$&@\"")),
            KeyboardRow(keys: [
                KeyboardKey(kind: .lettersToggle),
                KeyboardKey(kind: .symbolToggle),
                KeyboardKey(kind: .space),
                KeyboardKey(kind: .returnKey),
                KeyboardKey(kind: .backspace)
            ])
        ]
    )
}

private func characters(_ string: String) -> [KeyboardKey] {
    string.map { KeyboardKey(kind: .character(String($0))) }
}
