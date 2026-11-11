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
                .foregroundStyle(Theme.primaryText(scheme))
                .frame(width: size, height: size)
                .background(Circle().fill(Theme.fill(scheme)))
                .contentShape(Circle())
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .help(label)
    }
}
