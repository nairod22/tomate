import SwiftUI
import TomateCore

/// Menu bar time, snooze length, open at login.
struct GeneralSection: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var scheme
    /// Read from SMAppService in `task`, not in the initializer: the initial value
    /// expression would otherwise run each time the parent rebuilds this view.
    @State private var launchAtLogin = false

    var body: some View {
        @Bindable var settings = settings
        SettingsGroup(title: "Général") {
            SettingsRow {
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
            SettingsRow {
                Text("Durée du snooze").font(.system(size: 13, weight: .semibold))
                Spacer()
                Stepper(value: $settings.snoozeMinutes, in: AppSettings.snoozeRange) {
                    Text("\(settings.snoozeMinutes) min")
                        .font(.system(size: 13, weight: .semibold).monospacedDigit())
                }
                .fixedSize()
            }
            GroupDivider()
            SettingsRow {
                Text("Ouvrir au démarrage").font(.system(size: 13, weight: .semibold))
                Spacer()
                // Custom binding on purpose: the write goes through SMAppService, which
                // can refuse, so the displayed state is read back from the system.
                Toggle("Ouvrir au démarrage", isOn: Binding(get: { launchAtLogin }, set: setLaunchAtLogin))
                    .toggleStyle(.switch)
                    .tint(Theme.blue)
                    .labelsHidden()
            }
        }
        .task { launchAtLogin = LoginItem.isEnabled }
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        LoginItem.set(enabled)
        launchAtLogin = LoginItem.isEnabled
    }
}
