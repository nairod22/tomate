import SwiftUI
import TomateCore

/// One selectable mode on the home screen.
struct PresetRow: View {
    let preset: Preset
    let selected: Bool
    let select: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: select) {
            HStack(spacing: 10) {
                Text(preset.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.primaryText(scheme))
                Spacer(minLength: 8)
                Text("\(preset.work)/\(preset.pause) × \(preset.cycles)")
                    .font(.system(size: 12, weight: .medium).monospacedDigit())
                    .foregroundStyle(Theme.secondaryText(scheme))
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.work(scheme))
                    .opacity(selected ? 1 : 0)
                    .frame(width: 14)
            }
            .padding(.horizontal, 14)
            .frame(height: 40)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(preset.name), \(preset.summary)")
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}
