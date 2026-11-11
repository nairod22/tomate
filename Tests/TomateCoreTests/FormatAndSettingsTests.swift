import Foundation
import Testing
@testable import TomateCore

@Suite("Format")
struct FormatTests {
    @Test(arguments: [(45, "45 min"), (60, "1 h"), (135, "2 h 15"), (125, "2 h 05"), (180, "3 h")])
    func duration(_ minutes: Int, _ expected: String) {
        #expect(Format.duration(minutes: minutes) == expected)
    }

    @Test(arguments: [(1500.0, "25:00"), (1499.2, "25:00"), (61.0, "01:01"), (5400.0, "90:00"), (0.0, "00:00")])
    func countdown(_ seconds: Double, _ expected: String) {
        #expect(Format.countdown(.seconds(seconds)) == expected)
    }

    @Test func menuBarMinutes() {
        #expect(Format.menuBarMinutes(25) == "25 min")
    }
}

@MainActor
@Suite("Settings persistence")
struct SettingsTests {
    private func freshDefaults() -> UserDefaults {
        let name = "tomate.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func defaultsWhenEmpty() {
        let settings = AppSettings(defaults: freshDefaults())
        #expect(settings.presets == Preset.defaults)
        #expect(settings.activePreset == Preset.defaults[0])
        #expect(settings.showMenuBarTime)
        #expect(settings.snoozeMinutes == 5)
    }

    @Test func roundTrip() {
        let defaults = freshDefaults()
        let settings = AppSettings(defaults: defaults)
        settings.presets[1].work = 30
        settings.activePresetID = "classic"
        settings.showMenuBarTime = false
        settings.volume = 0.2

        let reloaded = AppSettings(defaults: defaults)
        #expect(reloaded.activePreset.work == 30)
        #expect(!reloaded.showMenuBarTime)
        #expect(reloaded.volume == 0.2)
    }

    @Test func corruptOrEmptyPresetsFallBack() {
        let defaults = freshDefaults()
        defaults.set(Data("not json".utf8), forKey: "presets")
        #expect(AppSettings(defaults: defaults).presets == Preset.defaults)
        defaults.set(try! JSONEncoder().encode([Preset]()), forKey: "presets")
        #expect(AppSettings(defaults: defaults).presets == Preset.defaults)
    }

    @Test func unknownActiveIDFallsBackToFirst() {
        let defaults = freshDefaults()
        defaults.set("gone", forKey: "activePresetID")
        let settings = AppSettings(defaults: defaults)
        #expect(settings.activePreset == settings.presets[0])
        #expect(settings.activeIndex == 0)
    }
}
