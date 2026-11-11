import SwiftUI
import TomateCore

/// Shown when no session is running: start first, then pick a mode.
struct HomeView: View {
    let openSettings: () -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(TimerEngine.self) private var engine
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let active = settings.activePreset
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                PrimaryButton(title: "Démarrer \(active.name)", systemImage: "play.fill", action: start)
                    .keyboardShortcut(.defaultAction)
                IconButton(systemName: "slider.horizontal.3", label: "Réglages", size: 44, action: openSettings)
            }

            VStack(spacing: 0) {
                ForEach(settings.presets.enumerated(), id: \.element.id) { index, preset in
                    if index > 0 { GroupDivider() }
                    PresetRow(preset: preset, selected: preset.id == settings.activePresetID) {
                        settings.activePresetID = preset.id
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: Theme.Radius.group).fill(Theme.group(scheme)))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.group).strokeBorder(Theme.groupStroke(scheme), lineWidth: 1))

            BlockEndLabel(totalMinutes: active.totalMinutes)
        }
        .padding(16)
    }

    private func start() {
        engine.start(settings.activePreset)
    }
}
