import Foundation

/// Display strings shared by the menu bar and the popover.
public enum Format {
    /// "2 h 15", "3 h", "45 min"
    public static func duration(minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        if h == 0 { return "\(m) min" }
        if m == 0 { return "\(h) h" }
        return "\(h) h \(m.formatted(.number.precision(.integerLength(2)).grouping(.never)))"
    }

    /// "32:14", seconds rounded up (minutes can exceed 59, e.g. "90:00").
    public static func countdown(_ remaining: Duration) -> String {
        let seconds = max(0, Int(remaining.timeInterval.rounded(.up)))
        let mm = (seconds / 60).formatted(.number.precision(.integerLength(2...)).grouping(.never))
        let ss = (seconds % 60).formatted(.number.precision(.integerLength(2)).grouping(.never))
        return "\(mm):\(ss)"
    }

    /// "25 min" for the menu bar.
    public static func menuBarMinutes(_ minutes: Int) -> String {
        "\(minutes) min"
    }

    /// "11:15"
    public static func clock(_ date: Date) -> String {
        date.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }
}
