import SwiftUI

@main
struct BashkirKeyboardApp: App {
    @StateObject private var settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settingsStore)
        }
    }
}
