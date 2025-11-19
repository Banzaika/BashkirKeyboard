import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore

    var body: some View {
        NavigationStack {
            Form {
                Section("Тактильная отдача") {
                    Toggle(isOn: $settingsStore.hapticsEnabled) {
                        Text("Включить вибрацию клавиш")
                    }
                }

                Section("Тема клавиатуры") {
                    Picker("Тема", selection: $settingsStore.selectedTheme) {
                        ForEach(KeyboardTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                }

                Section("Справка") {
                    Text("Настройки синхронизируются с клавиатурой через App Group: \(SharedAppGroup.identifier). Убедитесь, что обе цели используют один и тот же идентификатор.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Настройки")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsStore())
}
