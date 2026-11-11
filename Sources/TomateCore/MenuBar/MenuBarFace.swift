/// Everything the menu bar icon shows. Two equal faces render the same pixels,
/// so the app re-renders only when the face changes.
public struct MenuBarFace: Equatable, Sendable {
    public enum Mode: Equatable, Sendable { case idle, running, paused }

    public let mode: Mode
    /// Wedge fill, quantized to `MenuBarSchedule.steps` steps per turn.
    public let progressStep: Int
    /// Minutes left, rounded up. Nil when no countdown is shown.
    public let minutesLeft: Int?

    public init(mode: Mode, progressStep: Int, minutesLeft: Int?) {
        self.mode = mode
        self.progressStep = progressStep
        self.minutesLeft = minutesLeft
    }

    /// Wedge fill as a fraction, 0...1.
    public var progress: Double { Double(progressStep) / Double(MenuBarSchedule.steps) }

    /// "25 min", or nil when the tomato is shown alone.
    public var text: String? { minutesLeft.map(Format.menuBarMinutes) }

    /// VoiceOver label for the status item.
    public var accessibilityLabel: String {
        let left = minutesLeft.map { $0 == 1 ? ", 1 minute restante" : ", \($0) minutes restantes" } ?? ""
        switch mode {
        case .idle: return "Tomate, prêt"
        case .paused: return "Tomate, en pause\(left)"
        case .running: return "Tomate, en cours\(left)"
        }
    }
}
