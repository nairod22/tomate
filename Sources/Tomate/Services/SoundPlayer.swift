import AppKit

/// Plays macOS system sounds (/System/Library/Sounds).
@MainActor
enum SoundPlayer {
    private static let directory = URL(fileURLWithPath: "/System/Library/Sounds")
    private static var current: NSSound?

    /// Name → file URL, sorted by name.
    static let available: [(name: String, url: URL)] = {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: nil)) ?? []
        return files
            .filter { ["aiff", "aif", "caf", "wav", "m4a"].contains($0.pathExtension.lowercased()) }
            .map { (name: $0.deletingPathExtension().lastPathComponent, url: $0) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }()

    static var names: [String] { available.map(\.name) }

    static func play(_ name: String, volume: Double) {
        current?.stop()
        guard let url = available.first(where: { $0.name == name })?.url ?? available.first?.url,
              let sound = NSSound(contentsOf: url, byReference: true) else {
            NSSound.beep()
            return
        }
        sound.volume = Float(min(1, max(0, volume)))
        sound.play()
        current = sound
    }
}
