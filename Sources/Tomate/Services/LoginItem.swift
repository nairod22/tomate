import ServiceManagement

/// "Open at login" through SMAppService (needs the app to run from its .app bundle).
@MainActor
enum LoginItem {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func set(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Tomate: login item change failed: \(error.localizedDescription)")
        }
    }
}
