import Testing
@testable import TomateCore

@MainActor
@Suite("Menu bar face")
struct MenuBarScheduleTests {
    @Test(arguments: [
        (1500.0, 25), (1441.0, 25), (1440.0, 24), (61.0, 2), (60.0, 1), (59.0, 1), (0.5, 1), (5400.0, 90),
    ])
    func minutesRoundUp(_ seconds: Double, _ expected: Int) {
        #expect(MenuBarSchedule.minutesLeft(.seconds(seconds), minute: .seconds(60)) == expected)
    }

    @Test func zeroRemainingShowsZero() {
        #expect(MenuBarSchedule.minutesLeft(.zero, minute: .seconds(60)) == 0)
    }

    @Test func textAndLabel() {
        let face = MenuBarFace(mode: .running, progressStep: 0, minutesLeft: 25)
        #expect(face.text == "25 min")
        #expect(face.accessibilityLabel == "Tomate, en cours, 25 minutes restantes")
        let last = MenuBarFace(mode: .paused, progressStep: 0, minutesLeft: 1)
        #expect(last.accessibilityLabel == "Tomate, en pause, 1 minute restante")
    }

    @Test func faceFollowsTheState() {
        let h = Harness()
        #expect(h.faces.last?.mode == .idle)
        #expect(h.faces.last?.minutesLeft == nil)

        h.engine.start(Preset.defaults[1])
        #expect(h.faces.last == MenuBarFace(mode: .running, progressStep: 0, minutesLeft: 25))

        h.clock.advance(by: .seconds(61))
        #expect(h.faces.last?.minutesLeft == 24)

        h.engine.togglePause()
        #expect(h.faces.last?.mode == .paused)

        h.engine.reset()
        #expect(h.faces.last?.mode == .idle)
    }

    @Test func hidingTheTimeDropsTheText() {
        let h = Harness()
        h.showsTime = false
        h.engine.start(Preset.defaults[1])
        #expect(h.faces.last?.text == nil)
    }

    @Test func nextChangeIsNilWhenFrozen() {
        let h = Harness()
        let now = h.clock.now
        #expect(MenuBarSchedule.nextChange(for: h.engine.session, at: now, showsTime: true) == nil)
        h.engine.start(Preset.defaults[1])
        h.engine.togglePause()
        #expect(MenuBarSchedule.nextChange(for: h.engine.session, at: h.clock.now, showsTime: true) == nil)
    }

    @Test func nextChangeIsTheEarlierOfMinuteAndWedge() throws {
        let h = Harness()
        h.engine.start(Preset.defaults[1])  // 25 min: wedge step every 37.5 s
        let next = MenuBarSchedule.nextChange(for: h.engine.session, at: h.clock.now, showsTime: true)
        let wait = try #require(next.map { h.clock.now.duration(to: $0) })
        #expect(abs((wait - .milliseconds(37_500)).timeInterval) < 0.001, "wait: \(wait)")
    }
}
