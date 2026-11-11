import SwiftUI
import AppKit

/// Borderless panel that can take keyboard focus (for Return = main action).
private final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Full-screen blocking popup on every display, shown when a phase ends.
@MainActor
final class BlockingOverlay {
    private var panels: [NSPanel] = []
    private let engine: TimerEngine
    private let settings: AppSettings

    init(engine: TimerEngine, settings: AppSettings) {
        self.engine = engine
        self.settings = settings
    }

    var isVisible: Bool { !panels.isEmpty }

    func show(_ finished: Finished) {
        hide()
        // Card goes on the screen under the mouse (where the user is looking).
        let mouse = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let mainID = (screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main ?? screens.first)
            .map(Self.displayID)
        var keyPanel: NSPanel?
        for screen in screens {
            let isMain = Self.displayID(screen) == mainID
            let panel = OverlayPanel(
                contentRect: screen.frame,
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.level = .screenSaver
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = false
            panel.isMovable = false
            panel.hidesOnDeactivate = false
            panel.isReleasedWhenClosed = false

            let view = OverlayView(
                finished: finished,
                showsCard: isMain,
                proceed: { [weak self] in self?.engine.proceed(); self?.hide() },
                snooze: { [weak self] in
                    guard let self else { return }
                    engine.snooze(minutes: settings.snoozeMinutes)
                    hide()
                }
            )
            .environment(engine)
            .environment(settings)

            let blur = NSVisualEffectView(frame: CGRect(origin: .zero, size: screen.frame.size))
            blur.material = .fullScreenUI
            blur.blendingMode = .behindWindow
            blur.state = .active
            blur.autoresizingMask = [.width, .height]

            let host = NSHostingView(rootView: view)
            host.frame = blur.bounds
            host.autoresizingMask = [.width, .height]
            blur.addSubview(host)
            panel.contentView = blur
            panel.setFrame(screen.frame, display: true)
            panel.orderFrontRegardless()
            if isMain { keyPanel = panel }
            panels.append(panel)
        }
        NSApp.activate()
        keyPanel?.makeKeyAndOrderFront(nil)
    }

    private static func displayID(_ screen: NSScreen) -> UInt32 {
        (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? 0
    }

    func hide() {
        panels.forEach { $0.orderOut(nil) }
        panels.removeAll()
    }
}

struct OverlayView: View {
    let finished: Finished
    let showsCard: Bool
    let proceed: () -> Void
    let snooze: () -> Void

    @Environment(TimerEngine.self) private var engine
    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Color.black.opacity(scheme == .dark ? 0.3 : 0.18)
            if showsCard { card }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private var card: some View {
        let p = engine.preset
        return VStack(spacing: 6) {
            icon
                .frame(width: 64, height: 64)
                .background(Circle().fill(accent.opacity(scheme == .dark ? 0.16 : 0.12)))
                .padding(.bottom, 8)
            Text(title)
                .font(.system(size: 19, weight: .bold))
                .accessibilityAddTraits(.isHeader)
            Text(message(p))
                .font(.system(size: 13))
                .lineSpacing(2)
                .foregroundStyle(scheme == .dark ? Color(hex: 0xEBEBF5, opacity: 0.75) : Color(hex: 0x48484A))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 8) {
                primaryButton
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
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.25), radius: 35, y: 15)
    }

    private var accent: Color {
        switch finished {
        case .work: Theme.work(scheme)
        case .pause: Theme.pause(scheme)
        case .block: Theme.work(scheme)
        }
    }

    @ViewBuilder private var icon: some View {
        if finished == .block {
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in Circle().fill(accent).frame(width: 11, height: 11) }
            }
        } else {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(accent)
        }
    }

    private var title: String {
        switch finished {
        case .work: "Session de travail terminée"
        case .pause: "Pause terminée"
        case .block: "Bloc terminé"
        }
    }

    private func message(_ p: Preset) -> String {
        switch finished {
        case .work:
            "Cycle \(engine.cycle) sur \(p.cycles) bouclé. Prochaine étape : \(p.pause) min de pause."
        case .pause:
            "Prochaine étape : cycle \(engine.cycle + 1) sur \(p.cycles), \(p.work) min de travail."
        case .block:
            "\(p.cycles) cycles bouclés · \(Format.duration(minutes: p.focusMinutes)) de focus."
        }
    }

    @ViewBuilder private var primaryButton: some View {
        switch finished {
        case .work:
            PrimaryButton(title: "Passer à la pause", action: proceed)
        case .pause:
            PrimaryButton(title: "Reprendre le travail", color: Theme.blue, action: proceed)
        case .block:
            PrimaryButton(title: "Terminer le bloc", action: proceed)
        }
    }
}
