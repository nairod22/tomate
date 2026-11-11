/// Decides what the menu bar shows and when it next needs to change.
///
/// The icon is 18 pt and its wedge has a 4.5 pt radius, so 40 steps per turn are
/// below what the eye can tell apart. The countdown shows whole minutes. Together
/// this means about two redraws per minute while running and none otherwise,
/// instead of one per second.
public enum MenuBarSchedule {
    /// Wedge steps per full turn.
    public static let steps = 40
    /// Wedge fill shown while idle (the landing-page glyph).
    public static let idleStep = steps / 4

    public static func face(
        for session: PomodoroSession,
        at now: ContinuousClock.Instant,
        showsTime: Bool
    ) -> MenuBarFace {
        switch session.state {
        case .idle:
            return MenuBarFace(mode: .idle, progressStep: idleStep, minutesLeft: nil)
        case .awaiting:
            return MenuBarFace(mode: .running, progressStep: steps, minutesLeft: nil)
        case .running, .paused:
            let step = wedgeStep(session.progress(at: now))
            let minutes = showsTime ? minutesLeft(session.remaining(at: now), minute: session.minute) : nil
            return MenuBarFace(
                mode: session.isPaused ? .paused : .running,
                progressStep: step,
                minutesLeft: minutes
            )
        }
    }

    /// The next instant at which `face` changes, or nil when it is frozen
    /// (idle, paused, awaiting). The phase end itself is not included: the engine
    /// already wakes up for it and reports the transition.
    public static func nextChange(
        for session: PomodoroSession,
        at now: ContinuousClock.Instant,
        showsTime: Bool
    ) -> ContinuousClock.Instant? {
        guard case .running(_, let end) = session.state else { return nil }
        let remaining = session.remaining(at: now)
        guard remaining > .zero else { return nil }

        // Next wedge step: the moment progress reaches (step + 1) / steps.
        let length = session.phaseDuration
        let step = wedgeStep(session.progress(at: now))
        var candidates: [ContinuousClock.Instant] = []
        if step + 1 < steps {
            let left = length * (Double(steps - step - 1) / Double(steps))
            candidates.append(end - left)
        }

        // Next minute boundary: the countdown drops when remaining hits (m - 1) minutes.
        if showsTime {
            let m = minutesLeft(remaining, minute: session.minute)
            if m > 1 { candidates.append(end - session.minute * (m - 1)) }
        }

        return candidates.filter { $0 > now && $0 < end }.min()
    }

    /// Wedge step for a progress fraction. The epsilon keeps a wake-up planned for an
    /// exact step boundary from rounding back to the previous step.
    static func wedgeStep(_ progress: Double) -> Int {
        min(steps, Int((progress * Double(steps) + 1e-9).rounded(.down)))
    }

    /// Whole minutes left, rounded up, never below 1 while time remains.
    public static func minutesLeft(_ remaining: Duration, minute: Duration) -> Int {
        guard minute > .zero else { return 0 }
        let exact = remaining / minute
        return max(remaining > .zero ? 1 : 0, Int(exact.rounded(.up)))
    }
}
