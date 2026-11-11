import SwiftUI
import TomateCore

/// Popover router: home (mode choice) / timer / settings.
struct PopoverRoot: View {
    @Environment(TimerEngine.self) private var engine
    @State private var showSettings = false

    var body: some View {
        Group {
            if showSettings {
                SettingsView(close: closeSettings)
            } else if engine.isIdle {
                HomeView(openSettings: openSettings)
            } else {
                TimerView(openSettings: openSettings)
            }
        }
        .frame(width: 320)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func openSettings() { showSettings = true }
    private func closeSettings() { showSettings = false }
}
