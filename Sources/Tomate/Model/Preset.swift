import Foundation

/// One Pomodoro configuration: work minutes, pause minutes, number of work cycles.
struct Preset: Codable, Identifiable, Equatable, Sendable {
    var id: String
    var name: String
    var work: Int
    var pause: Int
    var cycles: Int

    /// Total focus time of a full block, in minutes.
    var focusMinutes: Int { work * cycles }

    /// Wall-clock length of a full block (no pause after the last cycle), in minutes.
    var totalMinutes: Int { work * cycles + pause * max(0, cycles - 1) }

    var summary: String { "\(work) min · pause \(pause) min · \(cycles) cycles" }
    var shortSummary: String { "\(work) / \(pause) · \(cycles) cycles" }

    static let defaults: [Preset] = [
        Preset(id: "deep", name: "Deep work", work: 45, pause: 15, cycles: 3),
        Preset(id: "classic", name: "Classique", work: 25, pause: 5, cycles: 4),
        Preset(id: "marathon", name: "Marathon", work: 90, pause: 15, cycles: 2),
    ]

    static let workRange = 1...180
    static let pauseRange = 1...60
    static let cyclesRange = 1...10
}

enum Format {
    /// "2 h 15", "3 h", "45 min"
    static func duration(minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        if h == 0 { return "\(m) min" }
        if m == 0 { return "\(h) h" }
        return String(format: "%d h %02d", h, m)
    }

    /// "32:14" (minutes can exceed 59, e.g. "90:00")
    static func countdown(_ seconds: TimeInterval) -> String {
        let s = max(0, Int(seconds.rounded(.up)))
        return String(format: "%02d:%02d", s / 60, s % 60)
    }

    /// "11:15"
    static func clock(_ date: Date) -> String {
        date.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }
}
