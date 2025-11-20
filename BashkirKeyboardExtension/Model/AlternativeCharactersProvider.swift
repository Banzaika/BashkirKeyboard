import Foundation

struct AlternativeCharactersProvider {
    private let mapping: [String: [String]]

    init(mapping: [String: [String]]) {
        self.mapping = mapping
    }

    func alternatives(for base: String) -> [String] {
        mapping[base.lowercased()] ?? []
    }

    static let `default` = AlternativeCharactersProvider(mapping: [
        "з": ["ҙ"],
        "с": ["ҫ"],
        "а": ["ә"],
        "у": ["ү"],
        "х": ["һ"],
        "о": ["ө"],
        "н": ["ң"],
        "г": ["ғ"],
        "к": ["ҡ"],
        "ь": ["ъ"]
    ])
}
