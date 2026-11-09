import SwiftUI
import AppKit

/// Debug: TOMATE_SNAPSHOT_DIR=/path renders every screen to PNG (light + dark) and quits.
@MainActor
enum DebugSnapshots {
    static func runIfRequested() {
        guard let dir = ProcessInfo.processInfo.environment["TOMATE_SNAPSHOT_DIR"] else { return }
        let url = URL(fileURLWithPath: dir)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        let settings = AppSettings()
        let engine = TimerEngine()

        for scheme in [ColorScheme.light, .dark] {
            let suffix = scheme == .dark ? "dark" : "light"
            func save<V: View>(_ name: String, _ view: V, width: CGFloat = 320) {
                let content = view
                    .frame(width: width)
                    .background(scheme == .dark ? Color(hex: 0x242428) : Color(hex: 0xF4EFEA))
                    .environment(settings)
                    .environment(engine)
                    .environment(\.colorScheme, scheme)
                let r = ImageRenderer(content: content)
                r.scale = 2
                guard let cg = r.cgImage else { return }
                let rep = NSBitmapImageRep(cgImage: cg)
                try? rep.representation(using: .png, properties: [:])?
                    .write(to: url.appendingPathComponent("\(name)-\(suffix).png"))
            }
            engine.reset()
            save("1-home", HomeView(openSettings: {}))
            save("2-settings", SettingsView(close: {}))
            engine.start(settings.activePreset)
            save("3-timer", TimerView(openSettings: {}))
            for (f, n) in [(Finished.work, "work"), (.pause, "pause"), (.block, "block")] {
                save("4-overlay-\(n)", OverlayView(finished: f, showsCard: true, proceed: {}, snooze: {})
                    .frame(height: 520), width: 520)
            }
            save("0-capsule-work", StatusCapsule(kind: .work, text: "32:14", dark: scheme == .dark), width: 90)
            save("0-capsule-pause", StatusCapsule(kind: .pause, text: "09:48", dark: scheme == .dark), width: 90)
            save("0-capsule-idle", StatusCapsule(kind: .idle, text: "Prêt", dark: scheme == .dark), width: 90)
        }
        exit(0)
    }
}
