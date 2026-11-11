import SwiftUI
import TomateCore

/// Large "32:14" countdown.
struct TimerCountdown: View {
    let remaining: Duration
    let isPaused: Bool
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Text(Format.countdown(remaining))
            .font(.system(size: 68, weight: .black).monospacedDigit())
            .tracking(-2.5)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .foregroundStyle(Theme.primaryText(scheme))
            .opacity(isPaused ? 0.4 : 1)
            .contentTransition(.numericText(countsDown: true))
            .animation(.easeInOut(duration: 0.2), value: isPaused)
    }
}
