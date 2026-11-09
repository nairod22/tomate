import SwiftUI
import AppKit

/// Menu bar indicator, proposition B "Capsule liquide".
/// Work: solid orange capsule. Pause: translucent mint capsule with a halo dot. Idle: outlined "Prêt".
struct StatusCapsule: View {
    enum Kind { case idle, work, pause }

    let kind: Kind
    let text: String
    let dark: Bool

    var body: some View {
        HStack(spacing: 5) {
            dot
            Text(text)
                .font(.system(size: 12, weight: .semibold).monospacedDigit())
        }
        .foregroundStyle(foreground)
        .padding(.leading, 7)
        .padding(.trailing, 9)
        .frame(height: 18)
        .background(Capsule().fill(background))
        .overlay(Capsule().strokeBorder(stroke, lineWidth: 1))
        .padding(.vertical, 2)
        .padding(.horizontal, 1)
    }

    @ViewBuilder private var dot: some View {
        switch kind {
        case .work:
            Circle().fill(.white).frame(width: 6, height: 6)
        case .pause:
            Circle().fill(Theme.pause(.dark))
                .frame(width: 6, height: 6)
                .background(Circle().fill(Theme.pause(.dark).opacity(0.3)).frame(width: 10, height: 10))
        case .idle:
            Circle().strokeBorder(foreground, lineWidth: 1.5).frame(width: 6, height: 6)
        }
    }

    private var foreground: Color {
        switch kind {
        case .work: .white
        case .pause: dark ? Color(hex: 0x5EEAD4) : Color(hex: 0x0F766E)
        case .idle: dark ? .white : .black.opacity(0.85)
        }
    }

    private var background: Color {
        switch kind {
        case .work: Color(hex: 0xC2410C)
        case .pause: Color(hex: 0x2DD4BF, opacity: dark ? 0.18 : 0.22)
        case .idle: dark ? .white.opacity(0.12) : .black.opacity(0.07)
        }
    }

    private var stroke: Color {
        switch kind {
        case .work: .white.opacity(0.2)
        case .pause: Color(hex: 0x2DD4BF, opacity: dark ? 0.3 : 0.45)
        case .idle: dark ? .white.opacity(0.14) : .black.opacity(0.1)
        }
    }

    @MainActor
    func render(scale: CGFloat) -> NSImage? {
        let renderer = ImageRenderer(content: self.environment(\.colorScheme, dark ? .dark : .light))
        renderer.scale = scale
        guard let image = renderer.nsImage else { return nil }
        image.isTemplate = false
        return image
    }
}
