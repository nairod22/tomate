import SwiftUI

/// Popover router: home (mode choice) / timer / settings.
struct PopoverRoot: View {
    @Environment(TimerEngine.self) private var engine
    @State private var showSettings = false

    var body: some View {
        Group {
            if showSettings {
                SettingsView(close: { showSettings = false })
            } else if engine.isIdle {
                HomeView(openSettings: { showSettings = true })
            } else {
                TimerView(openSettings: { showSettings = true })
            }
        }
        .frame(width: 320)
        .fixedSize(horizontal: false, vertical: true)
    }
}
