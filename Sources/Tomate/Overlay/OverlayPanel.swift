import AppKit

/// Borderless panel that can take keyboard focus (for Return = main action).
final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
