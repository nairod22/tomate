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

        observeMenuBarTimeSetting()
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

    /// Re-renders the status item whenever the "show time" setting flips.
    private func observeMenuBarTimeSetting() {
        withObservationTracking {
            _ = settings.showMenuBarTime
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.updateStatusItem()
                self?.observeMenuBarTimeSetting()
            }
        }
    }

    private func updateStatusItem() {
        guard let button = statusItem?.button else { return }
        let dark = button.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

        let state: StatusIcon.State
        switch engine.state {
        case .idle: state = .idle
        case .paused: state = .paused
        case .running, .awaiting: state = .running
        }
        let progress = engine.isIdle ? 0.25 : engine.progress
        let text = (settings.showMenuBarTime && !engine.isIdle) ? Format.countdown(engine.remaining) : nil

        let scale = button.window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2
        button.image = StatusIcon(state: state, progress: progress, text: text, dark: dark).render(scale: scale)

        let label: String
        switch state {
        case .idle: label = "Tomate, prêt"
        case .paused: label = "Tomate, en pause\(text.map { ", \($0)" } ?? "")"
        case .running: label = "Tomate, en cours\(text.map { ", \($0)" } ?? "")"
        }
        button.setAccessibilityLabel(label)
    }
}
