import SwiftUI

/// 44 pt horizontal row inside a settings group.
struct SettingsRow<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 8) { content }
            .padding(.horizontal, 12)
            .frame(height: 44)
    }
}
