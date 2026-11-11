/// What just ended and is waiting for the user's choice.
public enum Finished: Equatable, Sendable {
    /// A work session ended, a pause comes next.
    case work
    /// A pause ended, a work session comes next.
    case pause
    /// The last work session ended, the block is done.
    case block
}
