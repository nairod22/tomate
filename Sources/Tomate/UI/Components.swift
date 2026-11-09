import SwiftUI

/// 32 pt (or 44 pt) round neutral icon button.
struct IconButton: View {
    let systemName: String
    let label: String
    var size: CGFloat = 32
    let action: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size > 36 ? 16 : 13, weight: .semibold))
                .frame(width: size, height: size)
                .background(Circle().fill(Theme.fill(scheme)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .help(label)
    }
}

/// 44 pt filled capsule button.
struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    let color: Color
    var foreground: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage).font(.system(size: 12, weight: .bold)) }
                Text(title).font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                Capsule().fill(color)
                    .shadow(color: color.opacity(0.3), radius: 6, y: 3)
            )
            .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 0.5))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// 44 pt neutral capsule button.
struct SecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage { Image(systemName: systemImage).font(.system(size: 13, weight: .semibold)) }
                Text(title).font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Capsule().fill(Theme.fill(scheme)))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct Segment: Identifiable {
    let id: Int
    let weight: Double
    let color: Color
    /// 0...1 filled part.
    var fill: Double = 1
}

/// Horizontal bar of proportional segments with a 2 pt gap.
struct SegmentBar: View {
    let segments: [Segment]
    var height: CGFloat = 6
    var track: Color = .clear

    var body: some View {
        GeometryReader { geo in
            let total = max(0.0001, segments.map(\.weight).reduce(0, +))
            let avail = max(0, geo.size.width - CGFloat(max(0, segments.count - 1)) * 2)
            HStack(spacing: 2) {
                ForEach(segments) { s in
                    let w = avail * s.weight / total
                    ZStack(alignment: .leading) {
                        Capsule().fill(track)
                        Capsule().fill(s.color).frame(width: w * min(1, max(0, s.fill)))
                    }
                    .frame(width: w)
                }
            }
        }
        .frame(height: height)
    }
}

/// "− 45 +" field with a caption.
struct NumberStepper: View {
    let label: String
    let accessibilityName: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.secondaryText(scheme))
            HStack(spacing: 0) {
                stepButton("−", "Diminuer \(accessibilityName)") { value = max(range.lowerBound, value - 1) }
                Text("\(value)")
                    .font(.system(size: 13, weight: .semibold).monospacedDigit())
                    .frame(maxWidth: .infinity)
                stepButton("+", "Augmenter \(accessibilityName)") { value = min(range.upperBound, value + 1) }
            }
            .frame(height: 32)
            .background(RoundedRectangle(cornerRadius: 9).fill(Theme.field(scheme)))
            .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(Theme.fieldStroke(scheme), lineWidth: 1))
        }
    }

    private func stepButton(_ symbol: String, _ a11y: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(.system(size: 15))
                .frame(width: 24, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .buttonRepeatBehavior(.enabled)
        .accessibilityLabel(a11y)
    }
}

/// Grouped rounded section with an uppercase header.
struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Theme.secondaryText(scheme))
                .padding(.horizontal, 4)
            VStack(spacing: 0) { content }
                .background(RoundedRectangle(cornerRadius: 16).fill(Theme.group(scheme)))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.groupStroke(scheme), lineWidth: 1))
        }
    }
}

struct GroupDivider: View {
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        Rectangle().fill(Theme.separator(scheme)).frame(height: 1).padding(.horizontal, 12)
    }
}

extension Preset {
    /// Work/pause segments for one full block (no pause after the last cycle).
    func blockSegments(work: Color, pause: Color) -> [Segment] {
        var out: [Segment] = []
        for i in 0..<cycles {
            out.append(Segment(id: i * 2, weight: Double(self.work), color: work))
            if i < cycles - 1 {
                out.append(Segment(id: i * 2 + 1, weight: Double(self.pause), color: pause))
            }
        }
        return out
    }
}
