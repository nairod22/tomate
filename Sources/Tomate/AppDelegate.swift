import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = AppSettings()
    private let engine = TimerEngine()
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private lazy var overlay = BlockingOverlay(engine: engine, settings: settings)
    private var appearanceObservation: NSKeyValueObservation?

    func applicationDidFinishLaunching(_ notification: Notification) {
        DebugSnapshots.runIfRequested()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.imagePosition = .imageOnly
            button.setAccessibilityLabel("Tomate")
            appearanceObservation = button.observe(\.effectiveAppearance) { [weak self] _, _ in
                MainActor.assumeIsolated { self?.updateStatusItem() }
            }
        }

        let host = NSHostingController(
            rootView: PopoverRoot()
                .environment(settings)
                .environment(engine)
        )
        host.sizingOptions = [.preferredContentSize]
        popover.contentViewController = host
        popover.behavior = .transient
        popover.animates = true

        engine.onTick = { [weak self] in self?.updateStatusItem() }
        engine.onFinish = { [weak self] finished in self?.phaseFinished(finished) }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.engine.tick() }
        }

        updateStatusItem()

        // Debug: TOMATE_AUTOSTART=1 starts the active preset at launch.
        if ProcessInfo.processInfo.environment["TOMATE_AUTOSTART"] == "1" {
            engine.start(settings.activePreset)
        }
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            engine.tick()
            NSApp.activate()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func phaseFinished(_ finished: Finished) {
        if popover.isShown { popover.performClose(nil) }
        if settings.soundOn {
            SoundPlayer.play(settings.soundName, volume: settings.volume)
        }
        overlay.show(finished)
    }

    private func updateStatusItem() {
        guard let button = statusItem?.button else { return }
        let dark = button.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

        let kind: StatusCapsule.Kind
        let text: String
        switch engine.state {
        case .idle:
            kind = .idle; text = "Prêt"
        case .running(let p, _), .paused(let p, _):
            kind = p == .pause ? .pause : .work
            text = Format.countdown(engine.remaining)
        case .awaiting(let f):
            kind = f == .pause ? .pause : .work
            text = "00:00"
        }

        let scale = button.window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2
        button.image = StatusCapsule(kind: kind, text: text, dark: dark).render(scale: scale)
        button.alphaValue = engine.isPaused ? 0.6 : 1
    }
}
