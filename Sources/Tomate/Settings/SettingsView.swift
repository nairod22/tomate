import SwiftUI
import TomateCore

/// Réglages: presets, sound, snooze, login, quit.
struct SettingsView: View {
    let close: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                IconButton(systemName: "chevron.left", label: "Retour au minuteur", action: close)
                    .keyboardShortcut(.cancelAction)
                Text("Réglages")
                    .font(.system(size: 15, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
            }

            PresetsSection()
            SoundSection()
            GeneralSection()

            HStack {
                Spacer()
                Button("Quitter Tomate", action: quit)
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.secondaryText(scheme))
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .keyboardShortcut("q")
            }
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 14, trailing: 16))
    }

    private func quit() {
        NSApp.terminate(nil)
    }
}
