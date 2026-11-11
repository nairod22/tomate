/// Pure Pomodoro state machine. Every transition takes the current instant explicitly,
/// so it can be driven by a fake clock in tests and never reads the time itself.
public struct PomodoroSession: Equatable, Sendable {
    public private(set) var state: PomodoroState = .idle
    public private(set) var preset: Preset = Preset.defaults[0]
    /// 1-based current cycle.
    public private(set) var cycle = 1
    /// Length of the current phase segment, for progress.
    public private(set) var phaseDuration: Duration = .seconds(1)
    /// Length of one "minute". Debug builds shorten it to run a block in seconds.
    public let minute: Duration

    public init(minute: Duration = .seconds(60)) {
        self.minute = minute
    }

    // MARK: Derived

    public var phase: Phase? {
        switch state {
        case .running(let p, _), .paused(let p, _): p
        case .awaiting(.pause): .pause
        case .awaiting: .work
        case .idle: nil
        }
    }

    public var isIdle: Bool { state == .idle }
    public var isPaused: Bool { if case .paused = state { true } else { false } }
    public var isAwaiting: Bool { if case .awaiting = state { true } else { false } }
    public var isLastCycle: Bool { cycle >= preset.cycles }

    /// When the running phase ends, nil otherwise.
    public var deadline: ContinuousClock.Instant? {
        if case .running(_, let end) = state { end } else { nil }
    }

    public func remaining(at now: ContinuousClock.Instant) -> Duration {
        switch state {
        case .running(_, let end): max(.zero, now.duration(to: end))
        case .paused(_, let r): r
        case .idle, .awaiting: .zero
        }
    }

    /// Elapsed fraction of the current phase, 0...1.
    public func progress(at now: ContinuousClock.Instant) -> Double {
        guard phaseDuration > .zero else { return 1 }
        return min(1, max(0, 1 - remaining(at: now) / phaseDuration))
    }

    // MARK: Transitions

    public mutating func start(_ preset: Preset, at now: ContinuousClock.Instant) {
        self.preset = preset
        cycle = 1
        begin(.work, length: minute * preset.work, at: now)
    }

    /// Pauses or resumes. Pausing after the deadline has passed (before the finish
    /// timer fired) ends the phase instead, and returns what finished.
    public mutating func togglePause(at now: ContinuousClock.Instant) -> Finished? {
        if let finished = finishIfDue(at: now) { return finished }
        switch state {
        case .running(let p, let end):
            state = .paused(phase: p, remaining: max(.zero, now.duration(to: end)))
        case .paused(let p, let r):
            state = .running(phase: p, end: now + r)
        case .idle, .awaiting:
            break
        }
        return nil
    }

    /// Ends the current phase right away and moves on, without the blocking popup.
    public mutating func skip(at now: ContinuousClock.Instant) {
        guard let p = phase else { return }
        if !isAwaiting { state = .awaiting(finishedKind(for: p)) }
        proceed(at: now)
    }

    /// Main choice on the blocking popup: next phase, or end of block.
    public mutating func proceed(at now: ContinuousClock.Instant) {
        guard case .awaiting(let f) = state else { return }
        switch f {
        case .work:
            begin(.pause, length: minute * preset.pause, at: now)
        case .pause:
            cycle += 1
            begin(.work, length: minute * preset.work, at: now)
        case .block:
            reset()
        }
    }

    /// Extends the phase that just ended by `minutes`.
    public mutating func snooze(minutes: Int, at now: ContinuousClock.Instant) {
        guard case .awaiting(let f) = state else { return }
        begin(f == .pause ? .pause : .work, length: minute * minutes, at: now)
    }

    public mutating func reset() {
        state = .idle
        cycle = 1
    }

    /// Moves a running phase whose deadline has passed to `.awaiting`.
    /// Returns what finished, or nil when nothing was due.
    public mutating func finishIfDue(at now: ContinuousClock.Instant) -> Finished? {
        guard case .running(let p, let end) = state, now >= end else { return nil }
        let f = finishedKind(for: p)
        state = .awaiting(f)
        return f
    }

    // MARK: Internals

    private mutating func begin(_ phase: Phase, length: Duration, at now: ContinuousClock.Instant) {
        phaseDuration = length
        state = .running(phase: phase, end: now + length)
    }

    private func finishedKind(for phase: Phase) -> Finished {
        if phase == .pause { return .pause }
        return isLastCycle ? .block : .work
    }
}
