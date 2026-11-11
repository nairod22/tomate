import AppKit
import SwiftUI
import TomateCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = AppSettings()
    private let engine = TimerEngine(minute: DebugEnvironment.minute)
    private var statusItem: NSStatusItem?
    private var menuBar: MenuBarController?
    private let popover = NSPopover()
    private lazy var overlay = BlockingOverlay(engine: engine, settings: settings)

    func applicationDidFinishLaunching(_ notification: Notification) {
        DebugSnapshots.runIfRequested()

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item
        if let button = item.button {
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.imagePosition = .imageOnly
            menuBar = MenuBarController(button: button, engine: engine, settings: settings)
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

        engine.onChange = { [weak self] in self?.menuBar?.refresh() }
        engine.onFinish = { [weak self] finished in self?.phaseFinished(finished) }
        observeSystemEvents()

        if DebugEnvironment.autostart {
            engine.start(settings.activePreset)
            if DebugEnvironment.autopause { engine.togglePause() }
        }
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            engine.refresh()
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

    /// Sleep and clock changes: the deadline is monotonic, but a wake-up planned before
    /// sleep may fire late, so re-check right away.
    private func observeSystemEvents() {
        let workspace = NSWorkspace.shared.notificationCenter
        workspace.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.engine.refresh() }
        }
        workspace.addObserver(forName: NSWorkspace.screensDidWakeNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.overlay.rebuildIfVisible() }
        }
        NotificationCenter.default.addObserver(forName: .NSSystemClockDidChange, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.menuBar?.refresh(force: true) }
        }
    }
}
