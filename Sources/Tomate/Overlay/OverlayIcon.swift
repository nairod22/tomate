import SwiftUI
import TomateCore

/// Checkmark after a phase, three dots after a whole block.
struct OverlayIcon: View {
    let finished: Finished
    let accent: Color

    var body: some View {
        if finished == .block {
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle().fill(accent).frame(width: 11, height: 11)
                }
            }
            .accessibilityHidden(true)
        } else {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(accent)
                .accessibilityHidden(true)
        }
    }
}
