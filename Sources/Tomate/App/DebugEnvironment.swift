import Foundation

/// Debug switches read from the environment once at launch.
enum DebugEnvironment {
    private static let env = ProcessInfo.processInfo.environment

    /// TOMATE_SECONDS_PER_MINUTE=1 makes one minute last one second.
    static let minute: Duration = {
        if let v = env["TOMATE_SECONDS_PER_MINUTE"], let d = Double(v), d > 0 { return .seconds(d) }
        return .seconds(60)
    }()

    /// TOMATE_AUTOSTART=1 starts the active preset at launch.
    static let autostart = env["TOMATE_AUTOSTART"] == "1"

    /// TOMATE_AUTOPAUSE=1 pauses right after autostart (idle measurements).
    static let autopause = env["TOMATE_AUTOPAUSE"] == "1"
}
