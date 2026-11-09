import SwiftUI

/// Running session: phase, big countdown, cycle bars, controls.
struct TimerView: View {
    let openSettings: () -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(TimerEngine.self) private var engine
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let preset = engine.preset
        let isPause = engine.phase == .pause
        VStack(spacing: 16) {
            HStack {
                modeMenu(preset)
                Spacer()
                IconButton(systemName: "slider.horizontal.3", label: "Réglages", action: openSettings)
            }

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(isPause ? Theme.pause(scheme) : Theme.work(scheme))
                        .frame(width: 7, height: 7)
                    Text("\(isPause ? "Pause" : "Travail") · cycle \(engine.cycle) sur \(preset.cycles)")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isPause ? Theme.pauseText(scheme) : Theme.workText(scheme))

                Text(Format.countdown(engine.remaining))
                    .font(.system(size: 64, weight: .semibold).monospacedDigit())
                    .tracking(-2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText(countsDown: true))

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText(scheme))
            }
            .padding(.top, 4)

            cycleBars(preset)

            HStack(spacing: 10) {
                IconButton(systemName: "arrow.counterclockwise", label: "Réinitialiser", size: 44) {
                    engine.reset()
                }
                PrimaryButton(
                    title: engine.isPaused ? "Reprendre" : "Mettre en pause",
                    systemImage: engine.isPaused ? "play.fill" : "pause.fill",
                    color: isPause ? Theme.pauseButton : Theme.workButton
                ) {
                    engine.togglePause()
                }
                .keyboardShortcut(.space, modifiers: [])
                IconButton(systemName: "forward.end.fill", label: "Passer à l'étape suivante", size: 44) {
                    engine.skip()
                }
            }
        }
        .padding(16)
        .onAppear { engine.tick() }
    }

    private var subtitle: String {
        if engine.isPaused { return "En pause" }
        if case .awaiting = engine.state { return "En attente de ton choix" }
        guard let end = engine.phaseEndDate else { return "" }
        let at = Format.clock(end)
        if engine.phase == .pause { return "Reprise à \(at)" }
        return engine.isLastCycle ? "Fin du bloc à \(at)" : "Pause à \(at)"
    }

    private func modeMenu(_ preset: Preset) -> some View {
        Menu {
            Section("Changer de mode (redémarre le bloc)") {
                ForEach(settings.presets) { p in
                    Button("\(p.name) · \(p.work)/\(p.pause)") {
                        settings.activePresetID = p.id
                        engine.start(p)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(preset.name).font(.system(size: 13, weight: .semibold))
                Text("\(preset.work)/\(preset.pause)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.secondaryText(scheme))
                Image(systemName: "chevron.down").font(.system(size: 10, weight: .bold))
            }
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(Capsule().fill(Theme.fill(scheme)))
            .contentShape(Capsule())
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
    }

    private func cycleBars(_ preset: Preset) -> some View {
        let work = Theme.work(scheme), pause = Theme.pause(scheme)
        return HStack(spacing: 6) {
            ForEach(1...max(1, preset.cycles), id: \.self) { i in
                let (wf, pf) = fills(cycle: i)
                SegmentBar(
                    segments: [
                        Segment(id: 0, weight: Double(preset.work), color: work, fill: wf),
                        Segment(id: 1, weight: Double(preset.pause), color: pause, fill: pf),
                    ],
                    height: 6,
                    track: Theme.track(scheme)
                )
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Cycle \(engine.cycle) sur \(preset.cycles)")
    }

    /// (work fill, pause fill) for cycle `i`.
    private func fills(cycle i: Int) -> (Double, Double) {
        if i < engine.cycle { return (1, 1) }
        if i > engine.cycle { return (0, 0) }
        return engine.phase == .pause ? (1, engine.progress) : (engine.progress, 0)
    }
}
