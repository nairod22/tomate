import SwiftUI
import TomateCore

/// Presets list: the active one is editable, the others are one click away.
struct PresetsSection: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        SettingsGroup(title: "Préréglages") {
            ForEach(settings.presets.enumerated(), id: \.element.id) { index, preset in
                if index > 0 { GroupDivider() }
                if preset.id == settings.activePresetID {
                    ActivePresetEditor(index: index)
                } else {
                    PresetSummaryRow(preset: preset) {
                        settings.activePresetID = preset.id
                    }
                }
            }
        }
    }
}
