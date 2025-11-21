import SwiftUI

public enum ThemeManager {
    public static func tokens(for theme: KeyboardTheme, colorScheme: ColorScheme) -> KeyboardThemeTokens {
        switch theme {
        case .system:
            // System theme - adapts to device appearance (light/dark)
            if colorScheme == .dark {
                // Dark mode colors
                return KeyboardThemeTokens(
                    backgroundColor: color(hex: 0x2D2D2D),
                    keyBackgroundColor: color(hex: 0x6C6C6C),
                    specialKeyBackgroundColor: color(hex: 0x484848),
                    returnKeyBackgroundColor: color(hex: 0x484848),
                    keyForegroundColor: .white,
                    accentColor: Color(.systemBlue),
                    keyCornerRadius: 5,
                    keyShadow: Color.black.opacity(0.25),
                    keyShadowRadius: 2.0,
                    keyShadowOffset: CGSize(width: 0, height: 1.5),
                    blurStyle: nil
                )
            } else {
                // Light mode colors
                return KeyboardThemeTokens(
                    backgroundColor: color(hex: 0xD2D3D8),
                    keyBackgroundColor: color(hex: 0xFFFFFD),
                    specialKeyBackgroundColor: color(hex: 0xABB0BC),
                    returnKeyBackgroundColor: color(hex: 0xABB0BC),
                    keyForegroundColor: .black,
                    accentColor: Color(.systemBlue),
                    keyCornerRadius: 5,
                    keyShadow: Color.black.opacity(0.25),
                    keyShadowRadius: 2.0,
                    keyShadowOffset: CGSize(width: 0, height: 1.5),
                    blurStyle: nil
                )
            }
        case .dark, .classic:
            // Dark theme
            return KeyboardThemeTokens(
                backgroundColor: color(hex: 0x2D2D2D),
                keyBackgroundColor: color(hex: 0x6C6C6C),
                specialKeyBackgroundColor: color(hex: 0x484848),
                returnKeyBackgroundColor: color(hex: 0x484848),
                keyForegroundColor: .white,
                accentColor: Color(.systemBlue),
                keyCornerRadius: 5,
                keyShadow: Color.black.opacity(0.25),
                keyShadowRadius: 2.0,
                keyShadowOffset: CGSize(width: 0, height: 1.5),
                blurStyle: nil
            )
        case .light:
            return KeyboardThemeTokens(
                backgroundColor: color(hex: 0xD2D3D8),
                keyBackgroundColor: color(hex: 0xFFFFFD),
                specialKeyBackgroundColor: color(hex: 0xABB0BC),
                returnKeyBackgroundColor: color(hex: 0xABB0BC),
                keyForegroundColor: .black,
                accentColor: Color(.systemBlue),
                keyCornerRadius: 5,
                keyShadow: Color.black.opacity(0.25),
                keyShadowRadius: 2.0,
                keyShadowOffset: CGSize(width: 0, height: 1.5),
                blurStyle: nil
            )
        case .liquidGlass:
            // Liquid glass theme
            let translucentKey = Color(.sRGB, red: 60/255, green: 60/255, blue: 60/255, opacity: 0.5)
            let keyboardBackground = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.3)
            return KeyboardThemeTokens(
                backgroundColor: keyboardBackground,
                keyBackgroundColor: translucentKey,
                specialKeyBackgroundColor: translucentKey,
                returnKeyBackgroundColor: color(hex: 0x007AFE),
                keyForegroundColor: .white,
                accentColor: Color(.systemCyan),
                keyCornerRadius: 10,
                keyShadow: Color.black.opacity(0.25),
                keyShadowRadius: 2.0,
                keyShadowOffset: CGSize(width: 0, height: 1.5),
                blurStyle: .systemUltraThinMaterialDark
            )
        }
    }

    private static func color(hex: UInt, alpha: Double = 1.0) -> Color {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
