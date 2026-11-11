import SwiftUI
import TomateCore

/// "● Travail 2/4  pause à 11:15"
struct TimerStatusLine: View {
    @Environment(TimerEngine.self) private var engine
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let isPause = engine.phase == .pause
        HStack(spacing: 6) {
            Circle()
                .fill(isPause ? Theme.pause(scheme) : Theme.work(scheme))
                .frame(width: 6, height: 6)
            Text("\(isPause ? "Pause" : "Travail") \(engine.cycle)/\(engine.preset.cycles)")
                .foregroundStyle(Theme.primaryText(scheme))
            Text(detail)
                .foregroundStyle(Theme.secondaryText(scheme))
        }
        .font(.system(size: 12, weight: .medium).monospacedDigit())
    }

    private var detail: String {
        if engine.isPaused { return "en pause" }
        if engine.isAwaiting { return "en attente de ton choix" }
        guard let end = engine.phaseEndDate() else { return "" }
        let at = Format.clock(end)
        if engine.phase == .pause { return "reprise à \(at)" }
        return engine.isLastCycle ? "fin du bloc à \(at)" : "pause à \(at)"
    }
}
