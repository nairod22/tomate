import SwiftUI
import TomateCore

/// "Session de travail terminée" card: what ended, what comes next, two choices.
struct OverlayCard: View {
    let finished: Finished
    let proceed: () -> Void
    let snooze: () -> Void

    @Environment(TimerEngine.self) private var engine
    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 6) {
            OverlayIcon(finished: finished, accent: accent)
                .frame(width: 64, height: 64)
                .background(Circle().fill(accent.opacity(scheme == .dark ? 0.16 : 0.12)))
                .padding(.bottom, 8)
            Text(title)
                .font(.system(size: 19, weight: .bold))
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(.system(size: 13))
                .lineSpacing(2)
                .foregroundStyle(scheme == .dark ? Color(hex: 0xEBEBF5, opacity: 0.75) : Color(hex: 0x48484A))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 8) {
                PrimaryButton(title: primaryTitle, color: finished == .pause ? Theme.blue : nil, action: proceed)
                    .keyboardShortcut(.defaultAction)
                SecondaryButton(title: "Snooze \(settings.snoozeMinutes) min", systemImage: "clock", action: snooze)
            }
            .padding(.top, 14)

            Text("Reste au premier plan jusqu'à ton choix")
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText(scheme))
                .padding(.top, 6)
        }
        .foregroundStyle(Theme.primaryText(scheme))
        .padding(EdgeInsets(top: 28, leading: 24, bottom: 18, trailing: 24))
        .frame(width: 320)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .shadow(color: .black.opacity(0.25), radius: 35, y: 15)
    }

    private var accent: Color {
        switch finished {
        case .work, .block: Theme.work(scheme)
        case .pause: Theme.pause(scheme)
        }
    }

    private var title: String {
        switch finished {
        case .work: "Session de travail terminée"
        case .pause: "Pause terminée"
        case .block: "Bloc terminé"
        }
    }

    private var message: String {
        let p = engine.preset
        return switch finished {
        case .work:
            "Cycle \(engine.cycle) sur \(p.cycles) bouclé. Prochaine étape : \(p.pause) min de pause."
        case .pause:
            "Prochaine étape : cycle \(engine.cycle + 1) sur \(p.cycles), \(p.work) min de travail."
        case .block:
            "\(p.cycles) cycles bouclés · \(Format.duration(minutes: p.focusMinutes)) de focus."
        }
    }

    private var primaryTitle: String {
        switch finished {
        case .work: "Passer à la pause"
        case .pause: "Reprendre le travail"
        case .block: "Terminer le bloc"
        }
    }
}
