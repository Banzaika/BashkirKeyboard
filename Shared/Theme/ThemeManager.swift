import SwiftUI

public enum ThemeManager {
    public static func tokens(for theme: KeyboardTheme, colorScheme: ColorScheme) -> KeyboardThemeTokens {
        switch theme {
        case .system:
            return KeyboardThemeTokens(
                backgroundColor: Color(.systemBackground),
                keyBackgroundColor: Color(.secondarySystemBackground),
                keyForegroundColor: Color(.label),
                accentColor: Color(.systemBlue),
                keyCornerRadius: 6,
                keyShadow: Color.black.opacity(colorScheme == .dark ? 0 : 0.12),
                keyShadowRadius: 1,
                keyShadowOffset: CGSize(width: 0, height: 1),
                blurStyle: nil
            )
        case .classic:
            return KeyboardThemeTokens(
                backgroundColor: colorScheme == .dark ? Color.black : Color.white,
                keyBackgroundColor: colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.18) : Color(red: 0.92, green: 0.92, blue: 0.94),
                keyForegroundColor: colorScheme == .dark ? .white : .black,
                accentColor: Color(.systemOrange),
                keyCornerRadius: 5,
                keyShadow: Color.black.opacity(0.18),
                keyShadowRadius: 2,
                keyShadowOffset: CGSize(width: 0, height: 1),
                blurStyle: nil
            )
        case .liquidGlass:
            // TODO: Replace with new iOS 26 liquid glass material once it becomes available.
            return KeyboardThemeTokens(
                backgroundColor: Color.white.opacity(colorScheme == .dark ? 0.08 : 0.4),
                keyBackgroundColor: Color.white.opacity(colorScheme == .dark ? 0.16 : 0.45),
                keyForegroundColor: colorScheme == .dark ? Color(.systemTeal) : Color(.label),
                accentColor: Color(.systemCyan),
                keyCornerRadius: 12,
                keyShadow: Color.white.opacity(0.6),
                keyShadowRadius: 6,
                keyShadowOffset: CGSize(width: 0, height: 4),
                blurStyle: colorScheme == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight
            )
        }
    }
}
