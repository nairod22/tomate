import TomateCore

/// Engine + menu bar refresher wired like the app, on a fake clock.
@MainActor
final class Harness {
    let clock = ManualClock()
    let engine: TimerEngine
    let menuBar: MenuBarRefresher
    var showsTime = true
    private(set) var finished: [Finished] = []
    private(set) var faces: [MenuBarFace] = []

    init(minute: Duration = .seconds(60)) {
        engine = TimerEngine(time: clock, scheduler: clock, minute: minute)
        // The refresher's closures need `self`, which only exists once it is built.
        weak var weakSelf: Harness?
        menuBar = MenuBarRefresher(
            engine: engine,
            scheduler: clock,
            showsTime: { weakSelf?.showsTime ?? true },
            render: { weakSelf?.faces.append($0) }
        )
        weakSelf = self
        engine.onChange = { [weak self] in self?.menuBar.refresh() }
        engine.onFinish = { [weak self] in self?.finished.append($0) }
        menuBar.refresh()
    }

    /// Minutes as engine durations.
    func minutes(_ m: Double) -> Duration { engine.session.minute * m }
}
