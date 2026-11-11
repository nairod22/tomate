import SwiftUI
import TomateCore

/// Name field and work / pause / cycles steppers for the active preset.
struct ActivePresetEditor: View {
    let index: Int

    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        @Bindable var settings = settings
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                TextField("Nom du préréglage", text: $settings.presets[index].name)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(RoundedRectangle(cornerRadius: Theme.Radius.field).fill(Theme.field(scheme)))
                    .overlay(RoundedRectangle(cornerRadius: Theme.Radius.field).strokeBorder(Theme.fieldStroke(scheme), lineWidth: 1))
                Label("Actif", systemImage: "checkmark")
                    .labelStyle(ActiveBadgeLabelStyle())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.work(scheme))
                    .padding(.horizontal, 8)
                    .frame(height: 22)
                    .background(Capsule().fill(Theme.work(scheme).opacity(scheme == .dark ? 0.16 : 0.12)))
            }
            HStack(spacing: 8) {
                NumberStepper(label: "Travail (min)", accessibilityName: "le travail",
                              value: $settings.presets[index].work, range: Preset.workRange)
                NumberStepper(label: "Pause (min)", accessibilityName: "la pause",
                              value: $settings.presets[index].pause, range: Preset.pauseRange)
                NumberStepper(label: "Cycles", accessibilityName: "les cycles",
                              value: $settings.presets[index].cycles, range: Preset.cyclesRange)
            }
        }
        .padding(12)
    }
}
