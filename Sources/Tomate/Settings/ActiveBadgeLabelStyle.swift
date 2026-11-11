import SwiftUI

/// Tight icon + title for the small "Actif" badge.
struct ActiveBadgeLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon.font(.system(size: 8, weight: .heavy))
            configuration.title
        }
    }
}
