import SwiftUI

struct RootView: View {
    @EnvironmentObject private var settingsStore: SettingsStore

    var body: some View {
        TabView {
            WelcomeView()
                .tabItem {
                    Label("Добро пожаловать", systemImage: "hand.wave")
                }

            InstructionsView()
                .tabItem {
                    Label("Инструкция", systemImage: "list.clipboard")
                }

            SettingsView()
                .environmentObject(settingsStore)
                .tabItem {
                    Label("Настройки", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(SettingsStore())
}
