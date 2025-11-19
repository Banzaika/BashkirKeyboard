import SwiftUI

public enum KeyboardTheme: String, CaseIterable, Identifiable, Codable {
    case system
    case classic
    case liquidGlass

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .system: return "System"
        case .classic: return "Classic"
        case .liquidGlass: return "Liquid Glass"
        }
    }
}
