/// Where the engine reads the current instant. Injected so tests can drive time.
@MainActor
public protocol TimeSource: AnyObject {
    var now: ContinuousClock.Instant { get }
}

/// The real monotonic clock. It keeps counting while the Mac sleeps.
@MainActor
public final class SystemTime: TimeSource {
    public init() {}
    public var now: ContinuousClock.Instant { .now }
}
