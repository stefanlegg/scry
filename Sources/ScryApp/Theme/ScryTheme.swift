import SwiftUI

// MARK: - Theme Protocol

protocol ScryTheme {
    var name: String { get }
    
    // Backgrounds
    var background: Color { get }
    var surface: Color { get }
    var surfaceHover: Color { get }
    
    // Text
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textMuted: Color { get }
    
    // Status
    var statusRunning: Color { get }
    var statusRunningGlow: Color { get }
    var statusStopped: Color { get }
    
    // Accents
    var accentPrimary: Color { get }      // For branches, highlights
    var accentSecondary: Color { get }    // For watched badge
    var accentPin: Color { get }          // For pin icon
    
    // Borders & Dividers
    var border: Color { get }
    var divider: Color { get }
    
    // Effects
    var glowIntensity: Double { get }
    var glowRadius: CGFloat { get }
}

// MARK: - Default Theme (Native with Soul)

struct ScryDefaultTheme: ScryTheme {
    let name = "Default"
    
    // Deep purple-black, not pure black
    var background: Color { Color(hex: "1C1B22") }
    var surface: Color { Color(hex: "1C1B22").opacity(0.95) }
    var surfaceHover: Color { Color.white.opacity(0.04) }
    
    // Lavender-tinted whites
    var textPrimary: Color { Color(hex: "E8E6F0") }
    var textSecondary: Color { Color.white.opacity(0.45) }
    var textMuted: Color { Color.white.opacity(0.35) }
    
    // Status - green with glow
    var statusRunning: Color { Color(hex: "4ADE80") }
    var statusRunningGlow: Color { Color(hex: "4ADE80").opacity(0.5) }
    var statusStopped: Color { Color.white.opacity(0.2) }
    
    // Accents - warm gold for branches, blue for watched
    var accentPrimary: Color { Color(hex: "F5A623") }  // Gold/orange for git branches
    var accentSecondary: Color { Color(hex: "60A5FA") } // Blue for watched badge
    var accentPin: Color { Color(hex: "F5A623") }      // Gold for pin
    
    // Borders
    var border: Color { Color.white.opacity(0.08) }
    var divider: Color { Color.white.opacity(0.06) }
    
    // Effects
    var glowIntensity: Double { 0.5 }
    var glowRadius: CGFloat { 8 }
}

// MARK: - Minimal Theme (No effects)

struct ScryMinimalTheme: ScryTheme {
    let name = "Minimal"
    
    var background: Color { Color(NSColor.windowBackgroundColor) }
    var surface: Color { Color(NSColor.controlBackgroundColor) }
    var surfaceHover: Color { Color.primary.opacity(0.05) }
    
    var textPrimary: Color { Color.primary }
    var textSecondary: Color { Color.secondary }
    var textMuted: Color { Color.secondary.opacity(0.7) }
    
    var statusRunning: Color { Color.green }
    var statusRunningGlow: Color { Color.clear }
    var statusStopped: Color { Color.gray.opacity(0.3) }
    
    var accentPrimary: Color { Color.orange }
    var accentSecondary: Color { Color.blue }
    var accentPin: Color { Color.orange }
    
    var border: Color { Color.primary.opacity(0.1) }
    var divider: Color { Color.primary.opacity(0.08) }
    
    var glowIntensity: Double { 0 }
    var glowRadius: CGFloat { 0 }
}

// MARK: - Theme Environment

struct ThemeKey: EnvironmentKey {
    static let defaultValue: ScryTheme = ScryDefaultTheme()
}

extension EnvironmentValues {
    var theme: ScryTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
