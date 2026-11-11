import SwiftUI

/// Running session: pause control first, then the countdown and one quiet status line.
/// The mode can't be changed here: stop the session to pick another one.
struct TimerView: View {
    let openSettings: () -> Void

    @Environment(TimerEngine.self) private var engine
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let preset = engine.preset
        VStack(spacing: 18) {
            HStack(spacing: 8) {
                PrimaryButton(
                    title: engine.isPaused ? "Reprendre" : "Pause",
                    systemImage: engine.isPaused ? "play.fill" : "pause.fill"
                ) {
                    engine.togglePause()
                }
                .keyboardShortcut(.space, modifiers: [])

                IconButton(systemName: "forward.end.fill", label: "Passer à l'étape suivante", size: 44) {
                    engine.skip()
                }
                moreMenu
            }

            VStack(spacing: 4) {
                Text(Format.countdown(engine.remaining))
                    .font(.system(size: 68, weight: .black).monospacedDigit())
                    .tracking(-2.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(Theme.primaryText(scheme))
                    .opacity(engine.isPaused ? 0.4 : 1)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.easeInOut(duration: 0.2), value: engine.isPaused)

                statusLine(preset)
            }

            cycleBars(preset)
        }
        .padding(16)
        .onAppear { engine.tick() }
    }

    // MARK: Pieces

    private var moreMenu: some View {
        Menu {
            Button("Réglages", systemImage: "slider.horizontal.3", action: openSettings)
            Divider()
            Button("Arrêter la session", systemImage: "stop.fill") { engine.reset() }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.primaryText(scheme))
                .frame(width: 44, height: 44)
                .background(Circle().fill(Theme.fill(scheme)))
                .contentShape(Circle())
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityLabel("Plus d'options")
        .help("Plus d'options")
    }

    private func statusLine(_ preset: Preset) -> some View {
        let isPause = engine.phase == .pause
        return HStack(spacing: 6) {
            Circle()
                .fill(isPause ? Theme.pause(scheme) : Theme.work(scheme))
                .frame(width: 6, height: 6)
            Text("\(isPause ? "Pause" : "Travail") \(engine.cycle)/\(preset.cycles)")
                .foregroundStyle(Theme.primaryText(scheme))
            Text(detail)
                .foregroundStyle(Theme.secondaryText(scheme))
        }
        .font(.system(size: 12, weight: .medium).monospacedDigit())
    }

    private var detail: String {
        if engine.isPaused { return "en pause" }
        if case .awaiting = engine.state { return "en attente de ton choix" }
        guard let end = engine.phaseEndDate else { return "" }
        let at = Format.clock(end)
        if engine.phase == .pause { return "reprise à \(at)" }
        return engine.isLastCycle ? "fin du bloc à \(at)" : "pause à \(at)"
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
                    height: 4,
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
