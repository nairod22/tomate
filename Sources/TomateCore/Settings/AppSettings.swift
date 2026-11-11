import Foundation
import Observation

/// User preferences, persisted in UserDefaults.
@MainActor
@Observable
public final class AppSettings {
    private enum Key {
        static let presets = "presets"
        static let activePresetID = "activePresetID"
        static let soundOn = "soundOn"
        static let soundName = "soundName"
        static let volume = "volume"
        static let snoozeMinutes = "snoozeMinutes"
        static let showMenuBarTime = "showMenuBarTime"
    }

    @ObservationIgnored private let defaults: UserDefaults

    /// Written on every edit (each keystroke or stepper repeat while editing a preset).
    /// The payload is three small structs, so this stays cheap and needs no debouncing.
    public var presets: [Preset] {
        didSet {
            if let data = try? JSONEncoder().encode(presets) {
                defaults.set(data, forKey: Key.presets)
            }
        }
    }
    public var activePresetID: String { didSet { defaults.set(activePresetID, forKey: Key.activePresetID) } }
    public var soundOn: Bool { didSet { defaults.set(soundOn, forKey: Key.soundOn) } }
    public var soundName: String { didSet { defaults.set(soundName, forKey: Key.soundName) } }
    /// 0...1
    public var volume: Double { didSet { defaults.set(volume, forKey: Key.volume) } }
    public var snoozeMinutes: Int { didSet { defaults.set(snoozeMinutes, forKey: Key.snoozeMinutes) } }
    /// Remaining minutes next to the menu bar tomato.
    public var showMenuBarTime: Bool { didSet { defaults.set(showMenuBarTime, forKey: Key.showMenuBarTime) } }

    public static let snoozeRange = 1...30

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Key.presets),
           let saved = try? JSONDecoder().decode([Preset].self, from: data),
           !saved.isEmpty {
            presets = saved
        } else {
            presets = Preset.defaults
        }
        activePresetID = defaults.string(forKey: Key.activePresetID) ?? Preset.defaults[0].id
        soundOn = defaults.object(forKey: Key.soundOn) as? Bool ?? true
        soundName = defaults.string(forKey: Key.soundName) ?? "Glass"
        volume = defaults.object(forKey: Key.volume) as? Double ?? 0.7
        snoozeMinutes = defaults.object(forKey: Key.snoozeMinutes) as? Int ?? 5
        showMenuBarTime = defaults.object(forKey: Key.showMenuBarTime) as? Bool ?? true
    }

    public var activePreset: Preset {
        presets.first { $0.id == activePresetID } ?? presets[0]
    }

    public var activeIndex: Int {
        presets.firstIndex { $0.id == activePresetID } ?? 0
    }
}
