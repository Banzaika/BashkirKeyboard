import XCTest
@testable import KeyboardExtension

final class AlternativeCharactersProviderTests: XCTestCase {
    func testBashkirAlternatives() {
        let provider = AlternativeCharactersProvider.default
        XCTAssertEqual(provider.alternatives(for: "з"), ["ҙ"])
        XCTAssertEqual(provider.alternatives(for: "с"), ["ҫ"])
        XCTAssertEqual(provider.alternatives(for: "к"), ["ҡ"])
        XCTAssertTrue(provider.alternatives(for: "p").isEmpty)
    }
}

final class ThemeManagerTests: XCTestCase {
    func testLiquidGlassUsesBlurAndLargerRadius() {
        let tokens = ThemeManager.tokens(for: .liquidGlass, colorScheme: .light)
        XCTAssertNotNil(tokens.blurStyle)
        XCTAssertGreaterThan(tokens.keyCornerRadius, 8)
    }
}
