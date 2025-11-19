import Foundation

struct KeyboardRow: Identifiable {
    let id = UUID()
    let keys: [KeyboardKey]
}
