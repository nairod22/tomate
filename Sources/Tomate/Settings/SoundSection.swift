import SwiftUI
import TomateCore

/// End-of-phase sound: on/off, ringtone, volume.
struct SoundSection: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        @Bindable var settings = settings
        SettingsGroup(title: "Son") {
            SettingsRow {
                Text("Son en fin de phase").font(.system(size: 13, weight: .semibold))
                Spacer()
                Toggle("Son en fin de phase", isOn: $settings.soundOn)
                    .toggleStyle(.switch)
                    .tint(Theme.blue)
                    .labelsHidden()
            }
            GroupDivider()
            SettingsRow {
                Text("Sonnerie").font(.system(size: 13, weight: .semibold))
                Spacer()
                Picker("Sonnerie", selection: $settings.soundName) {
                    ForEach(SoundPlayer.names, id: \.self) { Text($0).tag($0) }
                }
                .labelsHidden()
                .fixedSize()
                .onChange(of: settings.soundName) { preview() }
                IconButton(systemName: "play.fill", label: "Écouter la sonnerie", size: 28, action: preview)
            }
            .disabled(!settings.soundOn)
            .opacity(settings.soundOn ? 1 : 0.4)
            GroupDivider()
            SettingsRow {
                Text("Volume").font(.system(size: 13, weight: .semibold))
                Image(systemName: settings.soundOn ? "speaker.fill" : "speaker.slash.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText(scheme))
                Slider(value: $settings.volume, in: 0...1, onEditingChanged: volumeEditingChanged)
                    .tint(Theme.work(scheme))
                    .accessibilityLabel("Volume")
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText(scheme))
            }
            .disabled(!settings.soundOn)
            .opacity(settings.soundOn ? 1 : 0.4)
        }
    }

    private func preview() {
        SoundPlayer.play(settings.soundName, volume: settings.volume)
    }

    private func volumeEditingChanged(_ editing: Bool) {
        if !editing { preview() }
    }
}
