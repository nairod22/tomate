import SwiftUI
import TomateCore

/// Running session: pause control first, then the countdown and one quiet status line.
/// The mode can't be changed here: stop the session to pick another one.
struct TimerView: View {
    let openSettings: () -> Void

    @Environment(TimerEngine.self) private var engine

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 8) {
                PrimaryButton(
                    title: engine.isPaused ? "Reprendre" : "Pause",
                    systemImage: engine.isPaused ? "play.fill" : "pause.fill",
                    action: engine.togglePause
                )
                .keyboardShortcut(.space, modifiers: [])

                IconButton(systemName: "forward.end.fill", label: "Passer à l'étape suivante", size: 44,
                           action: engine.skip)
                TimerMoreMenu(openSettings: openSettings, stop: engine.reset)
            }

            // Only this part ticks every second, and only while the popover is on screen.
            TimelineView(.periodic(from: tickOrigin, by: 1)) { _ in
                VStack(spacing: 18) {
                    VStack(spacing: 4) {
                        TimerCountdown(remaining: engine.remaining(), isPaused: engine.isPaused)
                        TimerStatusLine()
                    }
                    CycleBars(progress: engine.progress())
                }
            }
        }
        .padding(16)
    }

    /// Ticks aligned on the deadline's whole seconds, so the rounded-up countdown
    /// flips exactly when a second elapses.
    private var tickOrigin: Date {
        let remaining = engine.remaining().timeInterval
        return Date.now.addingTimeInterval(remaining - remaining.rounded(.up) - 1)
    }
}
