import AppKit
import Observation
import TomateCore

/// Owns the status item image. `MenuBarRefresher` decides when the face changes;
/// this class adds what only AppKit knows (appearance, backing scale) and draws.
/// Result: about two renders a minute while running, none while idle, paused or awaiting.
@MainActor
final class MenuBarController {
    private let button: NSStatusBarButton
    private let settings: AppSettings
    private var refresher: MenuBarRefresher?
    private var appearanceObservation: NSKeyValueObservation?

    init(
        button: NSStatusBarButton,
        engine: TimerEngine,
        settings: AppSettings,
        scheduler: any Scheduler = TaskScheduler()
    ) {
        self.button = button
        self.settings = settings
        refresher = MenuBarRefresher(
            engine: engine,
            scheduler: scheduler,
            showsTime: { [settings] in settings.showMenuBarTime },
            render: { [weak self] face in self?.render(face) }
        )

        appearanceObservation = button.observe(\.effectiveAppearance) { [weak self] _, _ in
            MainActor.assumeIsolated { self?.refresh(force: true) }
        }
        // Moving between Retina and non-Retina displays changes the backing scale.
        NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeBackingPropertiesNotification, object: nil, queue: .main
        ) { [weak self] note in
            let window = (note.object as AnyObject?).map(ObjectIdentifier.init)
            MainActor.assumeIsolated {
                guard let self, let own = self.button.window, window == ObjectIdentifier(own) else { return }
                self.refresh(force: true)
            }
        }
        observeShowTimeSetting()
        refresh()
    }

    /// Re-renders when the face changed, or always with `force` (appearance, scale, clock).
    func refresh(force: Bool = false) {
        refresher?.refresh(force: force)
    }

    private func render(_ face: MenuBarFace) {
        let dark = button.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let scale = button.window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2
        button.image = StatusIcon(face: face, dark: dark).render(scale: scale)
        button.setAccessibilityLabel(face.accessibilityLabel)
    }

    /// Re-renders whenever the "show time" setting flips.
    private func observeShowTimeSetting() {
        withObservationTracking {
            _ = settings.showMenuBarTime
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.refresh()
                self?.observeShowTimeSetting()
            }
        }
    }
}
