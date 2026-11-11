import Foundation
import Observation

/// User preferences, persisted in UserDefaults.
@MainActor
@Observable
final class AppSettings {
    private enum Key {
        static let presets = "presets"
        static let activePresetID = "activePresetID"
        static let soundOn = "soundOn"
        static let soundName = "soundName"
        static let volume = "volume"
        static let snoozeMinutes = "snoozeMinutes"
        static let showMenuBarTime = "showMenuBarTime"
    }

    @ObservationIgnored private let defaults = UserDefaults.standard

    var presets: [Preset] {
        didSet {
            if let data = try? JSONEncoder().encode(presets) {
                defaults.set(data, forKey: Key.presets)
            }
        }
    }
    var activePresetID: String { didSet { defaults.set(activePresetID, forKey: Key.activePresetID) } }
    var soundOn: Bool { didSet { defaults.set(soundOn, forKey: Key.soundOn) } }
    var soundName: String { didSet { defaults.set(soundName, forKey: Key.soundName) } }
    /// 0...1
    var volume: Double { didSet { defaults.set(volume, forKey: Key.volume) } }
    var snoozeMinutes: Int { didSet { defaults.set(snoozeMinutes, forKey: Key.snoozeMinutes) } }
    /// Countdown text next to the menu bar tomato.
    var showMenuBarTime: Bool { didSet { defaults.set(showMenuBarTime, forKey: Key.showMenuBarTime) } }

    static let snoozeRange = 1...30

    init() {
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

    var activePreset: Preset {
        presets.first { $0.id == activePresetID } ?? presets[0]
    }

    var activeIndex: Int {
        presets.firstIndex { $0.id == activePresetID } ?? 0
    }
}
