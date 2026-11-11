import SwiftUI
import TomateCore

/// "Fin du bloc vers 11:15", refreshed each minute while the popover is visible.
struct BlockEndLabel: View {
    let totalMinutes: Int
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        TimelineView(.everyMinute) { context in
            Text("Fin du bloc vers \(Format.clock(context.date.addingTimeInterval(TimeInterval(totalMinutes * 60))))")
                .font(.system(size: 12).monospacedDigit())
                .foregroundStyle(Theme.secondaryText(scheme))
        }
    }
}
