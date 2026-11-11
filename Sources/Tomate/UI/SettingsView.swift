import SwiftUI
import AppKit

/// Réglages: presets, sound, snooze, login, quit.
struct SettingsView: View {
    let close: () -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var scheme
    @State private var launchAtLogin = LoginItem.isEnabled

    var body: some View {
        @Bindable var settings = settings
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                IconButton(systemName: "chevron.left", label: "Retour au minuteur", action: close)
                    .keyboardShortcut(.cancelAction)
                Text("Réglages")
                    .font(.system(size: 15, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
            }

            SettingsGroup(title: "Préréglages") {
                ForEach(Array(settings.presets.enumerated()), id: \.element.id) { index, preset in
                    if index > 0 { GroupDivider() }
                    if preset.id == settings.activePresetID {
                        activeEditor(index: index)
                    } else {
                        Button {
                            settings.activePresetID = preset.id
                        } label: {
                            HStack {
                                Text(preset.name).font(.system(size: 13, weight: .semibold))
                                Spacer()
                                Text(preset.shortSummary)
                                    .font(.system(size: 12).monospacedDigit())
                                    .foregroundStyle(Theme.secondaryText(scheme))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Theme.secondaryText(scheme))
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            SettingsGroup(title: "Son") {
                row {
                    Text("Son en fin de phase").font(.system(size: 13, weight: .semibold))
                    Spacer()
                    Toggle("Son en fin de phase", isOn: $settings.soundOn)
                        .toggleStyle(.switch)
                        .tint(Theme.blue)
                        .labelsHidden()
                }
                GroupDivider()
                row {
                    Text("Sonnerie").font(.system(size: 13, weight: .semibold))
                    Spacer()
                    Picker("Sonnerie", selection: $settings.soundName) {
                        ForEach(SoundPlayer.names, id: \.self) { Text($0).tag($0) }
                    }
                    .labelsHidden()
                    .fixedSize()
                    .onChange(of: settings.soundName) { _, new in
                        SoundPlayer.play(new, volume: settings.volume)
                    }
                    IconButton(systemName: "play.fill", label: "Écouter la sonnerie", size: 28) {
                        SoundPlayer.play(settings.soundName, volume: settings.volume)
                    }
                }
                .disabled(!settings.soundOn)
                .opacity(settings.soundOn ? 1 : 0.4)
                GroupDivider()
                row {
                    Text("Volume").font(.system(size: 13, weight: .semibold))
                    Image(systemName: settings.soundOn ? "speaker.fill" : "speaker.slash.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText(scheme))
                    Slider(value: $settings.volume, in: 0...1) { editing in
                        if !editing { SoundPlayer.play(settings.soundName, volume: settings.volume) }
                    }
                    .tint(Theme.work(scheme))
                    .accessibilityLabel("Volume")
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText(scheme))
                }
                .disabled(!settings.soundOn)
                .opacity(settings.soundOn ? 1 : 0.4)
            }

            SettingsGroup(title: "Général") {
                row {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Afficher le temps").font(.system(size: 13, weight: .semibold))
                        Text("Dans la barre des menus")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.secondaryText(scheme))
                    }
                    Spacer()
                    Toggle("Afficher le temps dans la barre des menus", isOn: $settings.showMenuBarTime)
                        .toggleStyle(.switch)
                        .tint(Theme.blue)
                        .labelsHidden()
                }
                GroupDivider()
                row {
                    Text("Durée du snooze").font(.system(size: 13, weight: .semibold))
                    Spacer()
                    Stepper(value: $settings.snoozeMinutes, in: AppSettings.snoozeRange) {
                        Text("\(settings.snoozeMinutes) min")
                            .font(.system(size: 13, weight: .semibold).monospacedDigit())
                    }
                    .fixedSize()
                }
                GroupDivider()
                row {
                    Text("Ouvrir au démarrage").font(.system(size: 13, weight: .semibold))
                    Spacer()
                    Toggle("Ouvrir au démarrage", isOn: Binding(
                        get: { launchAtLogin },
                        set: { LoginItem.set($0); launchAtLogin = LoginItem.isEnabled }
                    ))
                    .toggleStyle(.switch)
                    .tint(Theme.blue)
                    .labelsHidden()
                }
            }

            HStack {
                Spacer()
                Button("Quitter Pomodoro") { NSApp.terminate(nil) }
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.secondaryText(scheme))
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .keyboardShortcut("q")
            }
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 14, trailing: 16))
        .onAppear { launchAtLogin = LoginItem.isEnabled }
    }

    private func row<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        HStack(spacing: 8) { content() }
            .padding(.horizontal, 12)
            .frame(height: 44)
    }

    @ViewBuilder
    private func activeEditor(index: Int) -> some View {
        @Bindable var settings = settings
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                TextField("Nom du préréglage", text: $settings.presets[index].name)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(RoundedRectangle(cornerRadius: 9).fill(Theme.field(scheme)))
                    .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(Theme.fieldStroke(scheme), lineWidth: 1))
                HStack(spacing: 4) {
                    Image(systemName: "checkmark").font(.system(size: 8, weight: .heavy))
                    Text("Actif")
                }
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
