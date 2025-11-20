import SwiftUI

struct UIKitThemePalette {
    let backgroundColor: UIColor
    let keyBackgroundColor: UIColor
    let specialKeyBackgroundColor: UIColor
    let returnKeyBackgroundColor: UIColor
    let keyForegroundColor: UIColor
    let accentColor: UIColor
    let keyCornerRadius: CGFloat
    let keyShadowColor: UIColor
    let keyShadowRadius: CGFloat
    let keyShadowOffset: CGSize
    let blurStyle: UIBlurEffect.Style?
}

enum ThemeBridge {
    static func palette(for tokens: KeyboardThemeTokens) -> UIKitThemePalette {
        UIKitThemePalette(
            backgroundColor: UIColor(tokens.backgroundColor),
            keyBackgroundColor: UIColor(tokens.keyBackgroundColor),
            specialKeyBackgroundColor: UIColor(tokens.specialKeyBackgroundColor),
            returnKeyBackgroundColor: UIColor(tokens.returnKeyBackgroundColor),
            keyForegroundColor: UIColor(tokens.keyForegroundColor),
            accentColor: UIColor(tokens.accentColor),
            keyCornerRadius: tokens.keyCornerRadius,
            keyShadowColor: UIColor(tokens.keyShadow),
            keyShadowRadius: tokens.keyShadowRadius,
            keyShadowOffset: tokens.keyShadowOffset,
            blurStyle: tokens.blurStyle
        )
    }
}
