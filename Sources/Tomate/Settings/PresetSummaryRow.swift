import SwiftUI
import TomateCore

/// Inactive preset: name and summary, selects it on click.
struct PresetSummaryRow: View {
    let preset: Preset
    let select: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: select) {
            HStack {
                Text(preset.name).font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(preset.shortSummary)
                    .font(.system(size: 12).monospacedDigit())
                    .foregroundStyle(Theme.secondaryText(scheme))
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.secondaryText(scheme))
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
