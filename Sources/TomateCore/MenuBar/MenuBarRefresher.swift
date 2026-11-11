/// Drives menu bar redraws: renders only when the face changes, then sleeps until
/// `MenuBarSchedule.nextChange`. Holds no AppKit so its wake-up and render counts
/// can be checked under a fake clock.
@MainActor
public final class MenuBarRefresher {
    private let engine: TimerEngine
    private let scheduler: any Scheduler
    private let showsTime: @MainActor () -> Bool
    private let render: @MainActor (MenuBarFace) -> Void
    private var lastFace: MenuBarFace?
    private var nextWake: (any ScheduledWake)?

    /// Faces actually rendered since creation.
    public private(set) var renderCount = 0

    public init(
        engine: TimerEngine,
        scheduler: any Scheduler,
        showsTime: @escaping @MainActor () -> Bool,
        render: @escaping @MainActor (MenuBarFace) -> Void
    ) {
        self.engine = engine
        self.scheduler = scheduler
        self.showsTime = showsTime
        self.render = render
    }

    /// Renders if the face changed (or `force`), then plans the next wake-up.
    public func refresh(force: Bool = false) {
        let now = engine.time.now
        let shows = showsTime()
        let face = MenuBarSchedule.face(for: engine.session, at: now, showsTime: shows)
        if force || face != lastFace {
            lastFace = face
            renderCount += 1
            render(face)
        }
        planNextWake(after: now, showsTime: shows)
    }

    private func planNextWake(after now: ContinuousClock.Instant, showsTime: Bool) {
        nextWake?.cancel()
        nextWake = nil
        guard let next = MenuBarSchedule.nextChange(for: engine.session, at: now, showsTime: showsTime) else {
            return
        }
        // 10 % of the wait, capped at 5 s: invisible on a minute countdown,
        // and lets the system batch this wake-up with others.
        let tolerance = min(.seconds(5), now.duration(to: next) / 10)
        nextWake = scheduler.schedule(at: next, tolerance: tolerance) { [weak self] in
            self?.nextWake = nil
            self?.refresh()
        }
    }
}
