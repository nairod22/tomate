import AppKit
import SwiftUI
import TomateCore

/// Full-screen blocking popup on every display, shown when a phase ends.
@MainActor
final class BlockingOverlay {
    private var panels: [NSPanel] = []
    private var shown: Finished?
    private let engine: TimerEngine
    private let settings: AppSettings

    init(engine: TimerEngine, settings: AppSettings) {
        self.engine = engine
        self.settings = settings
        // Displays plugged, unplugged or rearranged while the popup is up.
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.rebuildIfVisible() }
        }
    }

    var isVisible: Bool { shown != nil }

    func show(_ finished: Finished) {
        removePanels()
        shown = finished
        // Card goes on the screen under the mouse (where the user is looking).
        let mouse = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let mainID = (screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main ?? screens.first)
            .map(Self.displayID)
        var keyPanel: NSPanel?
        for screen in screens {
            let isMain = Self.displayID(screen) == mainID
            let panel = makePanel(for: screen, finished: finished, showsCard: isMain)
            panel.orderFrontRegardless()
            if isMain { keyPanel = panel }
            panels.append(panel)
        }
        NSApp.activate()
        keyPanel?.makeKeyAndOrderFront(nil)
    }

    /// Re-lays the panels out on the current displays (after wake or a display change).
    func rebuildIfVisible() {
        guard let shown else { return }
        show(shown)
    }

    func hide() {
        removePanels()
        shown = nil
    }

    private func removePanels() {
        panels.forEach { $0.orderOut(nil) }
        panels.removeAll()
    }

    private func proceed() {
        engine.proceed()
        hide()
    }

    private func snooze() {
        engine.snooze(minutes: settings.snoozeMinutes)
        hide()
    }

    private func makePanel(for screen: NSScreen, finished: Finished, showsCard: Bool) -> NSPanel {
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
            showsCard: showsCard,
            proceed: { [weak self] in self?.proceed() },
            snooze: { [weak self] in self?.snooze() }
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
        return panel
    }

    private static func displayID(_ screen: NSScreen) -> UInt32 {
        (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? 0
    }
}
