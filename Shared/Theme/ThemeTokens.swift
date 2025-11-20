import SwiftUI

public struct KeyboardThemeTokens {
    public let backgroundColor: Color
    public let keyBackgroundColor: Color
    public let specialKeyBackgroundColor: Color
    public let returnKeyBackgroundColor: Color
    public let keyForegroundColor: Color
    public let accentColor: Color
    public let keyCornerRadius: CGFloat
    public let keyShadow: Color
    public let keyShadowRadius: CGFloat
    public let keyShadowOffset: CGSize
    public let blurStyle: UIBlurEffect.Style?

    public init(backgroundColor: Color,
                keyBackgroundColor: Color,
                specialKeyBackgroundColor: Color,
                returnKeyBackgroundColor: Color,
                keyForegroundColor: Color,
                accentColor: Color,
                keyCornerRadius: CGFloat,
                keyShadow: Color,
                keyShadowRadius: CGFloat,
                keyShadowOffset: CGSize,
                blurStyle: UIBlurEffect.Style?) {
        self.backgroundColor = backgroundColor
        self.keyBackgroundColor = keyBackgroundColor
        self.specialKeyBackgroundColor = specialKeyBackgroundColor
        self.returnKeyBackgroundColor = returnKeyBackgroundColor
        self.keyForegroundColor = keyForegroundColor
        self.accentColor = accentColor
        self.keyCornerRadius = keyCornerRadius
        self.keyShadow = keyShadow
        self.keyShadowRadius = keyShadowRadius
        self.keyShadowOffset = keyShadowOffset
        self.blurStyle = blurStyle
    }
}
