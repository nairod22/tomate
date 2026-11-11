import SwiftUI
import AppKit

/// Menu bar indicator: the landing-page tomato, optionally followed by the countdown.
/// Running: the wedge fills with phase progress and a blue dot sits on the top-right.
/// Paused: no dot, pause bars inside the tomato, everything dimmed.
struct StatusIcon: View {
    enum State { case idle, running, paused }

    let state: State
    /// Elapsed fraction of the current phase, 0...1.
    var progress: Double = 0.25
    /// Countdown text, nil to show the tomato alone.
    var text: String? = nil
    let dark: Bool

    private var ink: Color { dark ? .white : .black.opacity(0.85) }

    var body: some View {
        HStack(spacing: 4) {
            TomatoGlyph(state: state, progress: progress, ink: ink)
                .frame(width: 18, height: 18)
            if let text {
                Text(text)
                    .font(.system(size: 12, weight: .semibold).monospacedDigit())
                    .foregroundStyle(ink)
            }
        }
        .opacity(state == .paused ? 0.5 : 1)
        .padding(.horizontal, 2)
        .frame(height: 22)
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

/// Tomato drawn on the landing SVG grid (120 × 120), scaled to fit.
private struct TomatoGlyph: View {
    let state: StatusIcon.State
    let progress: Double
    let ink: Color

    var body: some View {
        Canvas { ctx, size in
            let k = min(size.width, size.height) / 120
            func p(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x * k, y: y * k) }
            let center = p(60, 68)

            // Body outline.
            let body = Path(ellipseIn: CGRect(x: (60 - 42) * k, y: (68 - 42) * k, width: 84 * k, height: 84 * k))
            ctx.stroke(body, with: .color(ink), lineWidth: 12 * k)

            // Leaves + stem.
            var leaves = Path()
            leaves.addRoundedRect(in: CGRect(x: 55 * k, y: 2 * k, width: 10 * k, height: 26 * k),
                                  cornerSize: CGSize(width: 5 * k, height: 5 * k))
            for (cx, angle) in [(44.0, -25.0), (76.0, 25.0)] {
                let leaf = Path(ellipseIn: CGRect(x: -17 * k, y: -7 * k, width: 34 * k, height: 14 * k))
                    .applying(CGAffineTransform(rotationAngle: angle * .pi / 180))
                    .applying(CGAffineTransform(translationX: cx * k, y: 21 * k))
                leaves.addPath(leaf)
            }
            ctx.fill(leaves, with: .color(ink))

            switch state {
            case .paused:
                for x in [47.0, 64.0] {
                    let bar = Path(roundedRect: CGRect(x: x * k, y: 50 * k, width: 9 * k, height: 36 * k),
                                   cornerRadius: 3 * k)
                    ctx.fill(bar, with: .color(ink))
                }
            case .idle, .running:
                let sweep = min(1, max(0.04, progress))
                var wedge = Path()
                wedge.move(to: center)
                wedge.addArc(center: center, radius: 30 * k,
                             startAngle: .degrees(-90), endAngle: .degrees(-90 + 360 * sweep),
                             clockwise: false)
                wedge.closeSubpath()
                ctx.fill(wedge, with: .color(ink))
            }

            // Running dot, punched out of the glyph so it reads on any menu bar.
            if state == .running {
                let r = 15.0
                let c = CGPoint(x: 104 * k, y: 20 * k)
                let ring = Path(ellipseIn: CGRect(x: c.x - (r + 8) * k, y: c.y - (r + 8) * k,
                                                  width: 2 * (r + 8) * k, height: 2 * (r + 8) * k))
                ctx.blendMode = .destinationOut
                ctx.fill(ring, with: .color(.black))
                ctx.blendMode = .normal
                let dot = Path(ellipseIn: CGRect(x: c.x - r * k, y: c.y - r * k, width: 2 * r * k, height: 2 * r * k))
                ctx.fill(dot, with: .color(Theme.blue))
            }
        }
    }
}
