/// One Pomodoro configuration: work minutes, pause minutes, number of work cycles.
public struct Preset: Codable, Identifiable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var work: Int
    public var pause: Int
    public var cycles: Int

    public init(id: String, name: String, work: Int, pause: Int, cycles: Int) {
        self.id = id
        self.name = name
        self.work = work
        self.pause = pause
        self.cycles = cycles
    }

    /// Total focus time of a full block, in minutes.
    public var focusMinutes: Int { work * cycles }

    /// Wall-clock length of a full block (no pause after the last cycle), in minutes.
    public var totalMinutes: Int { work * cycles + pause * max(0, cycles - 1) }

    public var summary: String { "\(work) min · pause \(pause) min · \(cycles) cycles" }
    public var shortSummary: String { "\(work) / \(pause) · \(cycles) cycles" }

    public static let defaults: [Preset] = [
        Preset(id: "deep", name: "Deep work", work: 45, pause: 15, cycles: 3),
        Preset(id: "classic", name: "Classique", work: 25, pause: 5, cycles: 4),
        Preset(id: "marathon", name: "Marathon", work: 90, pause: 15, cycles: 2),
    ]

    public static let workRange = 1...180
    public static let pauseRange = 1...60
    public static let cyclesRange = 1...10
}
