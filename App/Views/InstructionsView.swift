import SwiftUI

struct InstructionsView: View {
    private let steps: [String] = [
        "Откройте Settings → General → Keyboard → Keyboards.",
        "Нажмите Add New Keyboard… и выберите Bashkir Keyboard.",
        "В разделе Keyboards нажмите Edit и включите Разрешить полный доступ (опционально для тем и тактильной отдачи).",
        "Откройте любое поле ввода и выберите нашу клавиатуру через значок глобуса."
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Как включить клавиатуру") {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .frame(width: 24, height: 24)
                                .background(Color.accentColor.opacity(0.2))
                                .clipShape(Circle())
                            Text(step)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Инструкция")
        }
    }
}

#Preview {
    InstructionsView()
}
