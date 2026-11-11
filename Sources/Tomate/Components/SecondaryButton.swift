import SwiftUI

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
