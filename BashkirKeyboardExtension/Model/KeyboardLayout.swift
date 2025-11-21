import Foundation

enum KeyboardLayoutMode {
    case letters
    case numbers
    case symbols
    case emoji
}

struct KeyboardLayout {
    let letterRows: [KeyboardRow]
    let numberRows: [KeyboardRow]
    let symbolRows: [KeyboardRow]
    let emojiBottomRow: KeyboardRow

    func rows(for mode: KeyboardLayoutMode) -> [KeyboardRow] {
        switch mode {
        case .letters:
            return letterRows
        case .numbers:
            return numberRows
        case .symbols:
            return symbolRows
        case .emoji:
            return []
        }
    }

    static let russian = KeyboardLayout(
        letterRows: [
            // Row 1: й ц у к е н г ш щ з х (Ъ removed completely)
            KeyboardRow(keys: characters("йцукенгшщзх")),
            // Row 2: ф ы в а п р о л д ж э
            KeyboardRow(keys: characters("фывапролджэ")),
            // Row 3: ⇧ я ч с м и т ь б ю ⌫ (ь contains ъ as long-press alternative)
            KeyboardRow(keys: [KeyboardKey(kind: .shift)] + characters("ячсмитьбю") + [KeyboardKey(kind: .backspace)]),
            // Row 4: 123 emoji space return (last row - no separate globe row)
            KeyboardRow(keys: [
                KeyboardKey(kind: .numbersToggle),
                KeyboardKey(kind: .emoji),
                KeyboardKey(kind: .space),
                KeyboardKey(kind: .returnKey)
            ])
        ],
        numberRows: [
            // Row 1: 1 2 3 4 5 6 7 8 9 0
            KeyboardRow(keys: characters("1234567890")),
            // Row 2: - / : ; ( ) ₽ & @ "
            KeyboardRow(keys: characters("-/:;()₽&@\"")),
            // Row 3: #+= space return ⌫
            KeyboardRow(keys: [
                KeyboardKey(kind: .symbolToggle),
                KeyboardKey(kind: .space),
                KeyboardKey(kind: .returnKey),
                KeyboardKey(kind: .backspace)
            ]),
            // Row 4: ABC (return to letters)
            KeyboardRow(keys: [
                KeyboardKey(kind: .lettersToggle)
            ])
        ],
        symbolRows: [
            // Row 1: [ ] { } # % ^ * + = _ (exactly like Apple)
            KeyboardRow(keys: characters("[]{}#%^*+=") + [KeyboardKey(kind: .character("_"))]),
            // Row 2: \ | ~ < > € £ ¥ • …
            KeyboardRow(keys: characters("\\|~<>€£¥•…")),
            // Row 3: 123 space return ⌫
            KeyboardRow(keys: [
                KeyboardKey(kind: .numbersToggle),
                KeyboardKey(kind: .space),
                KeyboardKey(kind: .returnKey),
                KeyboardKey(kind: .backspace)
            ]),
            // Row 4: ABC (return to letters)
            KeyboardRow(keys: [
                KeyboardKey(kind: .lettersToggle)
            ])
        ],
        emojiBottomRow: KeyboardRow(keys: [
            KeyboardKey(kind: .lettersToggle),
            KeyboardKey(kind: .emoji),
            KeyboardKey(kind: .space),
            KeyboardKey(kind: .returnKey)
        ])
    )
}

private func characters(_ string: String) -> [KeyboardKey] {
    string.map { KeyboardKey(kind: .character(String($0))) }
}
