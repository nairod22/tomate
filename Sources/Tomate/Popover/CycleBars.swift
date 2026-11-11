import SwiftUI
import TomateCore

/// One work/pause bar per cycle, filled up to the current progress.
struct CycleBars: View {
    /// Elapsed fraction of the current phase.
    let progress: Double

    @Environment(TimerEngine.self) private var engine
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let preset = engine.preset
        HStack(spacing: 6) {
            ForEach(1...max(1, preset.cycles), id: \.self) { i in
                let (workFill, pauseFill) = fills(cycle: i)
                SegmentBar(
                    segments: [
                        Segment(id: 0, weight: Double(preset.work), color: Theme.work(scheme), fill: workFill),
                        Segment(id: 1, weight: Double(preset.pause), color: Theme.pause(scheme), fill: pauseFill),
                    ],
                    height: 4,
                    track: Theme.track(scheme)
                )
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Cycle \(engine.cycle) sur \(preset.cycles)")
    }

    /// (work fill, pause fill) for cycle `i`.
    private func fills(cycle i: Int) -> (Double, Double) {
        if i < engine.cycle { return (1, 1) }
        if i > engine.cycle { return (0, 0) }
        return engine.phase == .pause ? (1, progress) : (progress, 0)
    }
}
