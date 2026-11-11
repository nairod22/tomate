/// Handle to a pending wake-up.
@MainActor
public protocol ScheduledWake: AnyObject {
    func cancel()
}

/// Runs one action at a future instant. The app never polls: every wake-up is planned
/// for the exact moment something visible changes.
@MainActor
public protocol Scheduler: AnyObject {
    func schedule(
        at deadline: ContinuousClock.Instant,
        tolerance: Duration,
        _ action: @escaping @MainActor () -> Void
    ) -> any ScheduledWake
}
