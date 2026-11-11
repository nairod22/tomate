import SwiftUI

/// Grouped rounded section with a quiet sentence-case header.
struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.secondaryText(scheme))
                .padding(.horizontal, 4)
            VStack(spacing: 0) { content }
                .background(RoundedRectangle(cornerRadius: Theme.Radius.group).fill(Theme.group(scheme)))
                .overlay(RoundedRectangle(cornerRadius: Theme.Radius.group).strokeBorder(Theme.groupStroke(scheme), lineWidth: 1))
        }
    }
}
