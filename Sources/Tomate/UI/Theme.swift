import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Colors from the design canvas.
enum Theme {
    // Work = orange, pause = mint/teal.
    static func work(_ s: ColorScheme) -> Color { s == .dark ? Color(hex: 0xFF8A4C) : Color(hex: 0xE8590C) }
    static func workText(_ s: ColorScheme) -> Color { s == .dark ? Color(hex: 0xFFAD80) : Color(hex: 0xC2410C) }
    static let workButton = Color(hex: 0xC2410C)

    static func pause(_ s: ColorScheme) -> Color { s == .dark ? Color(hex: 0x2DD4BF) : Color(hex: 0x0D9488) }
    static func pauseText(_ s: ColorScheme) -> Color { s == .dark ? Color(hex: 0x5EEAD4) : Color(hex: 0x0F766E) }
    static let pauseButton = Color(hex: 0x0F766E)

    static func primaryText(_ s: ColorScheme) -> Color { s == .dark ? Color(hex: 0xF5F5F7) : Color(hex: 0x1D1D1F) }
    static func secondaryText(_ s: ColorScheme) -> Color { s == .dark ? Color(hex: 0xEBEBF5, opacity: 0.7) : Color(hex: 0x5E5E63) }

    /// Neutral round-button / chip fill.
    static func fill(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.1) : .black.opacity(0.06) }
    /// Empty progress track.
    static func track(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.12) : .black.opacity(0.08) }
    /// Grouped section background.
    static func group(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.06) : .white.opacity(0.6) }
    static func groupStroke(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.08) : .black.opacity(0.06) }
    /// Input field.
    static func field(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.08) : .white.opacity(0.85) }
    static func fieldStroke(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.14) : .black.opacity(0.12) }
    static func separator(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.08) : .black.opacity(0.08) }
}
