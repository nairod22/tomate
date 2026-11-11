import Testing
@testable import TomateCore

/// Classic preset: 25 min work, 5 min pause, 4 cycles.
private let classic = Preset.defaults[1]
/// One work cycle only, to reach `.block` quickly.
private let single = Preset(id: "one", name: "One", work: 10, pause: 3, cycles: 1)

@MainActor
@Suite("Engine transitions")
struct EngineTransitionTests {
    @Test func startBeginsFirstWorkCycle() {
        let h = Harness()
        h.engine.start(classic)
        #expect(h.engine.phase == .work)
        #expect(h.engine.cycle == 1)
        #expect(h.engine.remaining() == h.minutes(25))
        #expect(h.engine.progress() == 0)
    }

    @Test func workEndAwaitsWorkChoice() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.advance(by: h.minutes(25))
        #expect(h.engine.state == .awaiting(.work))
        #expect(h.finished == [.work])
    }

    @Test func proceedAfterWorkStartsPause() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.advance(by: h.minutes(25))
        h.engine.proceed()
        #expect(h.engine.phase == .pause)
        #expect(h.engine.remaining() == h.minutes(5))
        #expect(h.engine.cycle == 1)
    }

    @Test func pauseEndThenProceedStartsNextCycle() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.advance(by: h.minutes(25))
        h.engine.proceed()
        h.clock.advance(by: h.minutes(5))
        #expect(h.engine.state == .awaiting(.pause))
        h.engine.proceed()
        #expect(h.engine.phase == .work)
        #expect(h.engine.cycle == 2)
    }

    @Test func lastWorkEndsBlockAndProceedResets() {
        let h = Harness()
        h.engine.start(single)
        h.clock.advance(by: h.minutes(10))
        #expect(h.engine.state == .awaiting(.block))
        h.engine.proceed()
        #expect(h.engine.isIdle)
        #expect(h.engine.cycle == 1)
    }

    @Test func skipFromRunningMovesOnWithoutFinishCallback() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.advance(by: h.minutes(3))
        h.engine.skip()
        #expect(h.engine.phase == .pause)
        #expect(h.engine.remaining() == h.minutes(5))
        #expect(h.finished.isEmpty)
    }

    @Test func skipFromPausedMovesOn() {
        let h = Harness()
        h.engine.start(classic)
        h.engine.togglePause()
        h.engine.skip()
        #expect(h.engine.phase == .pause)
        #expect(!h.engine.isPaused)
    }

    @Test func skipFromAwaitingActsLikeProceed() {
        let h = Harness()
        h.engine.start(classic)
        h.clock.advance(by: h.minutes(25))
        h.engine.skip()
        #expect(h.engine.phase == .pause)
        #expect(h.engine.cycle == 1)
    }

    @Test func skipWhileIdleDoesNothing() {
        let h = Harness()
        h.engine.skip()
        #expect(h.engine.isIdle)
    }

    @Test(arguments: [Finished.work, .pause, .block])
    func snoozeExtendsThePhaseThatEnded(_ kind: Finished) {
        let h = Harness()
        h.engine.start(kind == .block ? single : classic)
        h.clock.advance(by: h.minutes(kind == .block ? 10 : 25))
        if kind == .pause {
            h.engine.proceed()
            h.clock.advance(by: h.minutes(5))
        }
        #expect(h.engine.state == .awaiting(kind))
        h.engine.snooze(minutes: 3)
        #expect(h.engine.phase == (kind == .pause ? .pause : .work))
        #expect(h.engine.remaining() == h.minutes(3))
        h.clock.advance(by: h.minutes(3))
        #expect(h.engine.state == .awaiting(kind))
    }

    @Test func resetFromEveryState() {
        let h = Harness()
        h.engine.reset()
        #expect(h.engine.isIdle)

        h.engine.start(classic)
        h.engine.reset()
        #expect(h.engine.isIdle)

        h.engine.start(classic)
        h.engine.togglePause()
        h.engine.reset()
        #expect(h.engine.isIdle)

        h.engine.start(classic)
        h.clock.advance(by: h.minutes(25))
        h.engine.reset()
        #expect(h.engine.isIdle)
        #expect(h.clock.pendingCount == 0)
    }

    @Test func proceedAndSnoozeIgnoredUnlessAwaiting() {
        let h = Harness()
        h.engine.start(classic)
        let before = h.engine.session
        h.engine.proceed()
        h.engine.snooze(minutes: 5)
        #expect(h.engine.session == before)
    }
}
