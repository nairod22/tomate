import SwiftUI
import TomateCore

/// Menu bar indicator: the landing-page tomato, optionally followed by the minutes left.
/// Running: the wedge fills with phase progress and a blue dot sits on the top-right.
/// Paused: no dot, pause bars inside the tomato, everything dimmed.
struct StatusIcon: View {
    let face: MenuBarFace
    let dark: Bool

    private var ink: Color { dark ? .white : .black.opacity(0.85) }

    var body: some View {
        HStack(spacing: 4) {
            TomatoGlyph(mode: face.mode, progress: face.progress, ink: ink)
                .frame(width: 18, height: 18)
            if let text = face.text {
                Text(text)
                    .font(.system(size: 12, weight: .semibold).monospacedDigit())
                    .foregroundStyle(ink)
            }
        }
        .opacity(face.mode == .paused ? 0.5 : 1)
        .padding(.horizontal, 2)
        .frame(height: 22)
    }

    func render(scale: CGFloat) -> NSImage? {
        let renderer = ImageRenderer(content: environment(\.colorScheme, dark ? .dark : .light))
        renderer.scale = scale
        guard let image = renderer.nsImage else { return nil }
        image.isTemplate = false
        return image
    }
}
