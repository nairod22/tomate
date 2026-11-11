import Testing
@testable import TomateCore

/// Performance budgets, measured as wake-ups and renders under a fake clock.
/// Deterministic, so they can fail CI on a regression (the old 1 Hz timer
/// would show 1,500 wake-ups for a 25 minute phase).
@MainActor
@Suite("Wake-up budgets")
struct WakeBudgetTests {
    @Test func twentyFiveMinuteWorkPhase() {
        let h = Harness()
        h.engine.start(Preset.defaults[1])
        h.clock.resetWakeCount()
        let rendersBefore = h.menuBar.renderCount
        h.clock.advance(by: h.minutes(25))
        let wakes = h.clock.wakeCount
        let renders = h.menuBar.renderCount - rendersBefore
        print("[budget] 25 min work phase: \(wakes) wake-ups, \(renders) renders")
        // 24 minute flips + 39 wedge steps, some coinciding, + the finish.
        #expect(wakes <= 65, "wake-ups: \(wakes)")
        #expect(renders <= 65, "renders: \(renders)")
        #expect(h.finished == [.work])
    }

    @Test func ninetyMinuteMarathonStaysUnderTwoPerMinute() {
        let h = Harness()
        h.engine.start(Preset.defaults[2])
        h.clock.resetWakeCount()
        h.clock.advance(by: h.minutes(90))
        print("[budget] 90 min work phase: \(h.clock.wakeCount) wake-ups")
        #expect(h.clock.wakeCount <= 135, "wake-ups: \(h.clock.wakeCount)")
    }

    @Test func withoutMenuBarTimeOnlyWedgeStepsRemain() {
        let h = Harness()
        h.showsTime = false
        h.menuBar.refresh()
        h.engine.start(Preset.defaults[1])
        h.clock.resetWakeCount()
        h.clock.advance(by: h.minutes(25))
        print("[budget] 25 min, time hidden: \(h.clock.wakeCount) wake-ups")
        #expect(h.clock.wakeCount <= MenuBarSchedule.steps, "wake-ups: \(h.clock.wakeCount)")
    }

    @Test func pausedForTenMinutesNeverWakes() {
        let h = Harness()
        h.engine.start(Preset.defaults[1])
        h.engine.togglePause()
        h.clock.resetWakeCount()
        let renders = h.menuBar.renderCount
        h.clock.advance(by: h.minutes(10))
        #expect(h.clock.wakeCount == 0)
        #expect(h.menuBar.renderCount == renders)
    }

    @Test func awaitingForAnHourNeverWakes() {
        let h = Harness()
        h.engine.start(Preset.defaults[1])
        h.clock.advance(by: h.minutes(25))
        h.clock.resetWakeCount()
        h.clock.advance(by: .seconds(3600))
        #expect(h.clock.wakeCount == 0)
    }

    @Test func idleForAnHourNeverWakes() {
        let h = Harness()
        h.clock.resetWakeCount()
        h.clock.advance(by: .seconds(3600))
        #expect(h.clock.wakeCount == 0)
        #expect(h.menuBar.renderCount == 1)
    }

    @Test func everyWakeUpChangesWhatIsShown() {
        let h = Harness()
        h.engine.start(Preset.defaults[1])
        h.clock.resetWakeCount()
        let renders = h.menuBar.renderCount
        h.clock.advance(by: h.minutes(25))
        // No wasted wake-ups: each one renders a new face (the finish adds one).
        #expect(h.menuBar.renderCount - renders >= h.clock.wakeCount - 1)
    }
}
