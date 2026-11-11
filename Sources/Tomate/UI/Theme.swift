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

/// Colors from the landing page: blue = work, ink = pause.
enum Theme {
    /// Landing-page blue.
    static let blue = Color(hex: 0x009FE3)

    /// Work phase accent (progress, dots, toggles).
    static func work(_ s: ColorScheme) -> Color { s == .dark ? Color(hex: 0x33B5EA) : blue }
    /// Pause phase: ink, flipped to near-white in dark mode.
    static func pause(_ s: ColorScheme) -> Color { ink(s) }

    static func ink(_ s: ColorScheme) -> Color { s == .dark ? Color(hex: 0xF5F5F7) : Color(hex: 0x0B0B0B) }
    /// Text/icon color on an ink fill.
    static func onInk(_ s: ColorScheme) -> Color { s == .dark ? Color(hex: 0x0B0B0B) : .white }

    static func primaryText(_ s: ColorScheme) -> Color { s == .dark ? Color(hex: 0xF5F5F7) : Color(hex: 0x0B0B0B) }
    static func secondaryText(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.55) : Color(hex: 0x707070) }

    /// Neutral round-button / chip fill.
    static func fill(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.1) : .black.opacity(0.06) }
    /// Empty progress track.
    static func track(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.12) : .black.opacity(0.08) }
    /// Grouped section background.
    static func group(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.06) : .white.opacity(0.5) }
    static func groupStroke(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.08) : .black.opacity(0.06) }
    /// Input field.
    static func field(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.08) : .white.opacity(0.85) }
    static func fieldStroke(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.14) : .black.opacity(0.12) }
    static func separator(_ s: ColorScheme) -> Color { s == .dark ? .white.opacity(0.08) : .black.opacity(0.08) }
}
