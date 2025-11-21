import XCTest
@testable import KeyboardExtension

final class AlternativeCharactersProviderTests: XCTestCase {
    func testBashkirAlternatives() {
        let provider = AlternativeCharactersProvider.default
        XCTAssertEqual(provider.alternatives(for: "з")?.lowercase, ["ҙ"])
        XCTAssertEqual(provider.alternatives(for: "с")?.uppercase, ["Ҫ"])
        XCTAssertEqual(provider.alternatives(for: "к")?.uppercase, ["Ҡ"])
        XCTAssertNil(provider.alternatives(for: "p"))
    }
}

final class ThemeManagerTests: XCTestCase {
    func testLiquidGlassUsesBlurAndLargerRadius() {
        let tokens = ThemeManager.tokens(for: .liquidGlass, colorScheme: .light)
        XCTAssertNotNil(tokens.blurStyle)
        XCTAssertGreaterThan(tokens.keyCornerRadius, 8)
    }
}
