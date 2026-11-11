import Foundation
import Observation

/// Observable shell around `PomodoroSession`. It holds no per-second state: the only
/// wake-up it plans is the end of the running phase. Views that need a live countdown
/// read `remaining()` inside a `TimelineView`, which only ticks while on screen.
@MainActor
@Observable
public final class TimerEngine {
    public private(set) var session: PomodoroSession

    /// Called after every state transition (start, pause, finish, skip...).
    @ObservationIgnored public var onChange: (() -> Void)?
    /// Called once when a running phase reaches its deadline.
    @ObservationIgnored public var onFinish: ((Finished) -> Void)?

    @ObservationIgnored public let time: any TimeSource
    @ObservationIgnored private let scheduler: any Scheduler
    @ObservationIgnored private var finishWake: (any ScheduledWake)?

    /// How late the phase-end wake-up may fire, so the system can coalesce it.
    public static let finishTolerance: Duration = .milliseconds(500)

    public init(
        time: any TimeSource = SystemTime(),
        scheduler: any Scheduler = TaskScheduler(),
        minute: Duration = .seconds(60)
    ) {
        self.time = time
        self.scheduler = scheduler
        self.session = PomodoroSession(minute: minute)
    }

    // MARK: Derived

    public var state: PomodoroState { session.state }
    public var preset: Preset { session.preset }
    public var cycle: Int { session.cycle }
    public var phase: Phase? { session.phase }
    public var isIdle: Bool { session.isIdle }
    public var isPaused: Bool { session.isPaused }
    public var isAwaiting: Bool { session.isAwaiting }
    public var isLastCycle: Bool { session.isLastCycle }

    public func remaining() -> Duration { session.remaining(at: time.now) }
    public func progress() -> Double { session.progress(at: time.now) }

    /// Wall-clock time the current phase ends, for display only (nil unless running or paused).
    public func phaseEndDate(from date: Date = .now) -> Date? {
        switch session.state {
        case .running, .paused: date.addingTimeInterval(remaining().timeInterval)
        case .idle, .awaiting: nil
        }
    }

    // MARK: Actions

    public func start(_ preset: Preset) {
        update { $0.start(preset, at: time.now) }
    }

    public func togglePause() {
        var finished: Finished?
        update { finished = $0.togglePause(at: time.now) }
        if let finished { onFinish?(finished) }
    }

    public func skip() {
        update { $0.skip(at: time.now) }
    }

    public func proceed() {
        update { $0.proceed(at: time.now) }
    }

    public func snooze(minutes: Int) {
        update { $0.snooze(minutes: minutes, at: time.now) }
    }

    public func reset() {
        update { $0.reset() }
    }

    /// Re-checks the deadline. Call after wake-up or clock changes; harmless otherwise.
    public func refresh() {
        var finished: Finished?
        update { finished = $0.finishIfDue(at: time.now) }
        if let finished { onFinish?(finished) }
    }

    // MARK: Internals

    private func update(_ change: (inout PomodoroSession) -> Void) {
        var next = session
        change(&next)
        if next != session { session = next }
        planFinish()
        onChange?()
    }

    /// Keeps exactly one pending wake-up: at the deadline while running, none otherwise.
    private func planFinish() {
        finishWake?.cancel()
        finishWake = nil
        guard let deadline = session.deadline else { return }
        finishWake = scheduler.schedule(at: deadline, tolerance: Self.finishTolerance) { [weak self] in
            self?.finishWake = nil
            self?.refresh()
        }
    }
}
