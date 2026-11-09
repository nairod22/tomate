import Foundation
import Observation

enum Phase: Equatable, Sendable { case work, pause }

/// What just ended and is waiting for the user's choice.
enum Finished: Equatable, Sendable {
    case work    // a work session ended, a pause comes next
    case pause   // a pause ended, a work session comes next
    case block   // the last work session ended, the block is done
}

enum EngineState: Equatable {
    case idle
    case running(phase: Phase, endDate: Date)
    case paused(phase: Phase, remaining: TimeInterval)
    case awaiting(Finished)
}

/// Pomodoro state machine. Time is derived from an end date, so sleep/wake stays correct.
@MainActor
@Observable
final class TimerEngine {
    private(set) var state: EngineState = .idle
    /// 1-based current cycle.
    private(set) var cycle = 1
    private(set) var preset: Preset = Preset.defaults[0]
    /// Length of the current phase segment, for progress.
    private(set) var phaseDuration: TimeInterval = 1
    /// Refreshed every tick so views re-render.
    private(set) var now = Date()

    @ObservationIgnored var onTick: (() -> Void)?
    @ObservationIgnored var onFinish: ((Finished) -> Void)?
    @ObservationIgnored private var timer: Timer?

    /// Seconds per "minute". Debug: TOMATE_SECONDS_PER_MINUTE=2 makes a 45 min phase last 90 s.
    @ObservationIgnored let minute: TimeInterval = {
        if let v = ProcessInfo.processInfo.environment["TOMATE_SECONDS_PER_MINUTE"], let d = Double(v), d > 0 { return d }
        return 60
    }()

    // MARK: Derived

    var phase: Phase? {
        switch state {
        case .running(let p, _), .paused(let p, _): p
        case .awaiting(.pause): .pause
        case .awaiting: .work
        case .idle: nil
        }
    }

    var remaining: TimeInterval {
        switch state {
        case .running(_, let end): max(0, end.timeIntervalSince(now))
        case .paused(_, let r): r
        default: 0
        }
    }

    /// Elapsed fraction of the current phase, 0...1.
    var progress: Double {
        guard phaseDuration > 0 else { return 1 }
        return min(1, max(0, 1 - remaining / phaseDuration))
    }

    var isPaused: Bool { if case .paused = state { true } else { false } }
    var isIdle: Bool { state == .idle }
    var isLastCycle: Bool { cycle >= preset.cycles }

    /// When the current phase will end (nil if not running).
    var phaseEndDate: Date? {
        if case .running(_, let end) = state { return end }
        if case .paused(_, let r) = state { return now.addingTimeInterval(r) }
        return nil
    }

    // MARK: Actions

    func start(_ preset: Preset) {
        self.preset = preset
        cycle = 1
        begin(.work, seconds: TimeInterval(preset.work) * minute)
    }

    func togglePause() {
        switch state {
        case .running(let p, let end):
            state = .paused(phase: p, remaining: max(0, end.timeIntervalSinceNow))
        case .paused(let p, let r):
            state = .running(phase: p, endDate: Date().addingTimeInterval(r))
        default: break
        }
        tick()
    }

    func reset() {
        state = .idle
        cycle = 1
        stopTimer()
        tick()
    }

    /// Ends the current phase right away and moves on, without the blocking popup.
    func skip() {
        guard let p = phase, !isIdle else { return }
        if case .awaiting = state {} else { state = .awaiting(finishedKind(for: p)) }
        proceed()
    }

    /// Main choice on the blocking popup: next phase (or end of block).
    func proceed() {
        guard case .awaiting(let f) = state else { return }
        switch f {
        case .work:
            begin(.pause, seconds: TimeInterval(preset.pause) * minute)
        case .pause:
            cycle += 1
            begin(.work, seconds: TimeInterval(preset.work) * minute)
        case .block:
            reset()
        }
    }

    /// Extends the phase that just ended by `minutes`.
    func snooze(minutes: Int) {
        guard case .awaiting(let f) = state else { return }
        begin(f == .pause ? .pause : .work, seconds: TimeInterval(minutes) * minute)
    }

    // MARK: Internals

    private func begin(_ phase: Phase, seconds: TimeInterval) {
        phaseDuration = seconds
        state = .running(phase: phase, endDate: Date().addingTimeInterval(seconds))
        startTimer()
        tick()
    }

    private func finishedKind(for phase: Phase) -> Finished {
        if phase == .pause { return .pause }
        return isLastCycle ? .block : .work
    }

    func tick() {
        now = Date()
        if case .running(let p, let end) = state, now >= end {
            let f = finishedKind(for: p)
            state = .awaiting(f)
            stopTimer()
            onTick?()
            onFinish?(f)
            return
        }
        onTick?()
    }

    private func startTimer() {
        guard timer == nil else { return }
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        t.tolerance = 0.1
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
