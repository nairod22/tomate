import SwiftUI
import TomateCore

/// Dimmed full-screen backdrop, with the choice card on the main display.
struct OverlayView: View {
    let finished: Finished
    let showsCard: Bool
    let proceed: () -> Void
    let snooze: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Color.black.opacity(scheme == .dark ? 0.3 : 0.18)
            if showsCard {
                OverlayCard(finished: finished, proceed: proceed, snooze: snooze)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
