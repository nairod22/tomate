import SwiftUI

/// "…" menu next to the pause button: settings, stop.
struct TimerMoreMenu: View {
    let openSettings: () -> Void
    let stop: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Menu {
            Button("Réglages", systemImage: "slider.horizontal.3", action: openSettings)
            Divider()
            Button("Arrêter la session", systemImage: "stop.fill", action: stop)
        } label: {
            Label("Plus d'options", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.primaryText(scheme))
                .frame(width: 44, height: 44)
                .background(Circle().fill(Theme.fill(scheme)))
                .contentShape(.circle)
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .help("Plus d'options")
    }
}
