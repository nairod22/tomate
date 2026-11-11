import Testing
@testable import TomateCore

private let classic = Preset.defaults[1]

@MainActor
@Suite("Pause, sleep and rapid actions")
struct EdgeCaseTests {
    @Test func pauseFreezesRemainingAndPlansNothing() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.advance(by: h.minutes(10))
        h.engine.togglePause()
        #expect(h.clock.pendingCount == 0)
        h.clock.advance(by: h.minutes(120))
        #expect(h.engine.remaining() == h.minutes(15))
        #expect(h.finished.isEmpty)
    }

    @Test func resumeKeepsTheRemainder() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.advance(by: h.minutes(10))
        h.engine.togglePause()
        h.clock.advance(by: h.minutes(7))
        h.engine.togglePause()
        #expect(h.engine.remaining() == h.minutes(15))
        h.clock.advance(by: h.minutes(15))
        #expect(h.finished == [.work])
    }

    @Test func pausingPastTheDeadlineFinishesInstead() {
        let h = Harness()
        h.engine.start(classic)
        // The Mac slept through the deadline; the finish wake-up has not run yet.
        h.clock.sleep(for: h.minutes(30))
        h.engine.togglePause()
        #expect(h.engine.state == .awaiting(.work))
        #expect(h.finished == [.work])
    }

    @Test func wakeAfterLongSleepFinishesExactlyOnce() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.sleep(for: .seconds(3 * 3600))
        h.engine.refresh()          // didWake
        h.engine.refresh()          // a second notification, e.g. screens wake
        h.clock.advance(by: .seconds(1))  // the stale wake-up fires late
        #expect(h.finished == [.work])
        #expect(h.engine.state == .awaiting(.work))
    }

    @Test func refreshBeforeDeadlineChangesNothing() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.advance(by: h.minutes(5))
        let before = h.engine.session
        h.engine.refresh()
        #expect(h.engine.session == before)
        #expect(h.clock.pendingCount <= 2)  // engine finish + menu bar
    }

    @Test func rapidPauseTogglingKeepsOneFinishWakeUp() {
        let h = Harness()
        h.showsTime = false
        h.engine.start(classic)
        for _ in 0..<101 { h.engine.togglePause() }  // odd count: ends paused
        #expect(h.engine.isPaused)
        #expect(h.clock.pendingCount == 0)
        h.engine.togglePause()
        // One engine wake-up at the deadline, at most one menu bar wake-up.
        #expect(h.clock.pendingCount <= 2)
        #expect(h.engine.remaining() == h.minutes(25))
    }

    @Test func doubleProceedDoesNotSkipAPhase() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.advance(by: h.minutes(25))
        h.engine.proceed()
        h.engine.proceed()
        #expect(h.engine.phase == .pause)
        #expect(h.engine.cycle == 1)
    }

    @Test func restartWhileRunningStartsFresh() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.advance(by: h.minutes(20))
        h.engine.start(Preset.defaults[0])
        #expect(h.engine.remaining() == h.minutes(45))
        h.clock.advance(by: h.minutes(25))
        #expect(h.finished.isEmpty)  // the old deadline was cancelled
    }

    @Test(arguments: Preset.defaults)
    func fullBlockTakesTotalMinutes(_ preset: Preset) {
        let h = Harness()
        h.engine.start(preset)
        var elapsed = Duration.zero
        while !h.engine.isIdle {
            let left = h.engine.remaining()
            h.clock.advance(by: left)
            elapsed += left
            h.engine.proceed()
        }
        #expect(elapsed == h.engine.session.minute * preset.totalMinutes)
        #expect(h.finished.filter { $0 == .work }.count == preset.cycles - 1)
        #expect(h.finished.filter { $0 == .pause }.count == preset.cycles - 1)
        #expect(h.finished.last == .block)
    }
}
