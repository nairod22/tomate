import SwiftUI

/// "Choisis ton mode" — shown when no session is running.
struct HomeView: View {
    let openSettings: () -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(TimerEngine.self) private var engine
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let active = settings.activePreset
        VStack(spacing: 14) {
            HStack {
                Text("Choisis ton mode")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.leading, 4)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                IconButton(systemName: "slider.horizontal.3", label: "Réglages", action: openSettings)
            }

            VStack(spacing: 8) {
                ForEach(settings.presets) { preset in
                    PresetCard(preset: preset, selected: preset.id == settings.activePresetID) {
                        settings.activePresetID = preset.id
                    }
                }
            }

            PrimaryButton(title: "Démarrer \(active.name)", systemImage: "play.fill", color: Theme.workButton) {
                engine.start(active)
            }
            .keyboardShortcut(.defaultAction)

            Text("Fin du bloc vers \(Format.clock(engine.now.addingTimeInterval(TimeInterval(active.totalMinutes * 60))))")
                .font(.system(size: 12))
                .foregroundStyle(Theme.secondaryText(scheme))
                .padding(.top, -4)
        }
        .padding(16)
        .onAppear { engine.tick() }
    }
}

private struct PresetCard: View {
    let preset: Preset
    let selected: Bool
    let select: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: select) {
            HStack(spacing: 12) {
                radio
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(preset.name).font(.system(size: 14, weight: .semibold))
                        Spacer(minLength: 8)
                        Text("\(Format.duration(minutes: preset.focusMinutes)) de focus")
                            .font(.system(size: 12).monospacedDigit())
                            .foregroundStyle(Theme.secondaryText(scheme))
                    }
                    Text(preset.summary)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText(scheme))
                    SegmentBar(
                        segments: preset.blockSegments(work: Theme.work(scheme), pause: Theme.pause(scheme)),
                        height: 4
                    )
                    .opacity(selected ? 1 : 0.55)
                    .padding(.top, 2)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 16).fill(cardFill))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(selected ? Theme.work(scheme) : Theme.groupStroke(scheme),
                                  lineWidth: selected ? 1.5 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    private var cardFill: Color {
        if scheme == .dark { return .white.opacity(selected ? 0.1 : 0.05) }
        return .white.opacity(selected ? 0.8 : 0.45)
    }

    @ViewBuilder private var radio: some View {
        if selected {
            Circle()
                .fill(scheme == .dark ? Theme.work(scheme) : Theme.workButton)
                .frame(width: 20, height: 20)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(scheme == .dark ? Color(hex: 0x1D1D1F) : .white)
                )
        } else {
            Circle()
                .strokeBorder(scheme == .dark ? .white.opacity(0.35) : .black.opacity(0.28), lineWidth: 1.5)
                .frame(width: 20, height: 20)
        }
    }
}
