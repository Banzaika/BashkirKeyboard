import Foundation

struct AlternativeCharactersProvider {
    struct Alternatives {
        let lowercase: [String]
        let uppercase: [String]
    }

    private let mapping: [String: [String]]

    init(mapping: [String: [String]]) {
        self.mapping = mapping
    }

    func alternatives(for base: String) -> Alternatives? {
        guard let lowercase = mapping[base.lowercased()] else { return nil }
        let uppercase = lowercase.map { $0.uppercased() }
        return Alternatives(lowercase: lowercase, uppercase: uppercase)
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
