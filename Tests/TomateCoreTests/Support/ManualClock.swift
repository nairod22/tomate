import TomateCore

/// Fake time plus a scheduler that only fires when the test advances the clock.
/// Each fired action counts as one wake-up of the process.
@MainActor
final class ManualClock: TimeSource, Scheduler {
    private(set) var now: ContinuousClock.Instant
    /// Actions actually run (what would be CPU wake-ups in the real app).
    private(set) var wakeCount = 0

    private var pending: [Entry] = []
    private var nextID = 0

    init(start: ContinuousClock.Instant = .now) {
        now = start
    }

    var pendingCount: Int { pending.count }

    func schedule(
        at deadline: ContinuousClock.Instant,
        tolerance: Duration,
        _ action: @escaping @MainActor () -> Void
    ) -> any ScheduledWake {
        nextID += 1
        let id = nextID
        pending.append(Entry(id: id, deadline: deadline, action: action))
        return Wake { [weak self] in self?.pending.removeAll { $0.id == id } }
    }

    /// Moves time forward, firing every due action at its own deadline, in order.
    func advance(by duration: Duration) {
        let target = now + duration
        while let entry = pending.filter({ $0.deadline <= target }).min(by: { $0.deadline < $1.deadline }) {
            pending.removeAll { $0.id == entry.id }
            now = max(now, entry.deadline)
            wakeCount += 1
            entry.action()
        }
        now = target
    }

    /// Jumps forward without firing anything, like a Mac asleep with timers frozen.
    func sleep(for duration: Duration) {
        now = now + duration
    }

    func resetWakeCount() { wakeCount = 0 }

    private struct Entry {
        let id: Int
        let deadline: ContinuousClock.Instant
        let action: @MainActor () -> Void
    }

    private final class Wake: ScheduledWake {
        let onCancel: @MainActor () -> Void
        init(onCancel: @escaping @MainActor () -> Void) { self.onCancel = onCancel }
        func cancel() { onCancel() }
    }
}
