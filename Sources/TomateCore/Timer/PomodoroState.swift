/// Where the timer stands. Running phases store a monotonic deadline, so wall-clock
/// changes (time zone, NTP, manual edits) never move it, while system sleep still counts.
public enum PomodoroState: Equatable, Sendable {
    case idle
    case running(phase: Phase, end: ContinuousClock.Instant)
    case paused(phase: Phase, remaining: Duration)
    case awaiting(Finished)
}
