import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "keyboard")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(.tint)

                Text("Bashkir Keyboard for iOS")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Русская раскладка с башкирскими символами через долгое нажатие.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("Добро пожаловать")
        }
    }
}

#Preview {
    WelcomeView()
}
