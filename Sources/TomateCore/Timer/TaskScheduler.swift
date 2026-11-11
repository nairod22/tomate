/// Production scheduler: one sleeping task per wake-up on the continuous clock.
/// The tolerance lets the system coalesce the wake-up with other timers.
@MainActor
public final class TaskScheduler: Scheduler {
    public init() {}

    public func schedule(
        at deadline: ContinuousClock.Instant,
        tolerance: Duration,
        _ action: @escaping @MainActor () -> Void
    ) -> any ScheduledWake {
        let task = Task { @MainActor in
            do {
                try await Task.sleep(until: deadline, tolerance: tolerance, clock: .continuous)
            } catch {
                return  // cancelled
            }
            action()
        }
        return TaskWake(task: task)
    }
}

@MainActor
private final class TaskWake: ScheduledWake {
    private let task: Task<Void, Never>
    init(task: Task<Void, Never>) { self.task = task }
    func cancel() { task.cancel() }
}
