import Testing
@testable import TomateCore

/// The production scheduler, on the real continuous clock (short delays).
@MainActor
@Suite("TaskScheduler")
struct TaskSchedulerTests {
    @Test func firesAfterTheDeadline() async throws {
        let scheduler = TaskScheduler()
        let start = ContinuousClock.now
        var firedAt: ContinuousClock.Instant?
        _ = scheduler.schedule(at: start + .milliseconds(50), tolerance: .milliseconds(5)) {
            firedAt = .now
        }
        try await Task.sleep(for: .milliseconds(300))
        let fired = try #require(firedAt)
        #expect(start.duration(to: fired) >= .milliseconds(50))
    }

    @Test func cancelledWakeNeverFires() async throws {
        let scheduler = TaskScheduler()
        var fired = false
        let wake = scheduler.schedule(at: .now + .milliseconds(50), tolerance: .zero) { fired = true }
        wake.cancel()
        try await Task.sleep(for: .milliseconds(200))
        #expect(!fired)
    }

    @Test func engineFinishesOnTheRealClock() async throws {
        let engine = TimerEngine(minute: .milliseconds(20))
        var finished: [Finished] = []
        engine.onFinish = { finished.append($0) }
        engine.start(Preset(id: "t", name: "T", work: 2, pause: 1, cycles: 2))  // 40 ms
        try await Task.sleep(for: .milliseconds(800))
        #expect(finished == [.work])
    }
}
