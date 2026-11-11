import SwiftUI

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
                PrimaryButton(title: "Démarrer \(active.name)", systemImage: "play.fill") {
                    engine.start(active)
                }
                .keyboardShortcut(.defaultAction)
                IconButton(systemName: "slider.horizontal.3", label: "Réglages", size: 44, action: openSettings)
            }

            VStack(spacing: 0) {
                ForEach(Array(settings.presets.enumerated()), id: \.element.id) { index, preset in
                    if index > 0 { GroupDivider() }
                    PresetRow(preset: preset, selected: preset.id == settings.activePresetID) {
                        settings.activePresetID = preset.id
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.group(scheme)))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.groupStroke(scheme), lineWidth: 1))

            Text("Fin du bloc vers \(Format.clock(engine.now.addingTimeInterval(TimeInterval(active.totalMinutes * 60))))")
                .font(.system(size: 12).monospacedDigit())
                .foregroundStyle(Theme.secondaryText(scheme))
        }
        .padding(16)
        .onAppear { engine.tick() }
    }
}

private struct PresetRow: View {
    let preset: Preset
    let selected: Bool
    let select: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: select) {
            HStack(spacing: 10) {
                Text(preset.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.primaryText(scheme))
                Spacer(minLength: 8)
                Text("\(preset.work)/\(preset.pause) × \(preset.cycles)")
                    .font(.system(size: 12, weight: .medium).monospacedDigit())
                    .foregroundStyle(Theme.secondaryText(scheme))
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.work(scheme))
                    .opacity(selected ? 1 : 0)
                    .frame(width: 14)
            }
            .padding(.horizontal, 14)
            .frame(height: 40)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(preset.name), \(preset.summary)")
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}
