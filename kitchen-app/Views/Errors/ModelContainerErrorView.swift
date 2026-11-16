import SwiftUI

struct ModelContainerErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Не удалось открыть рецепты", systemImage: "exclamationmark.triangle")
        } description: {
            Text("Попробуйте открыть их ещё раз.")
        } actions: {
            Button("Повторить", action: onRetry)
        }
    }
}

#Preview {
    ModelContainerErrorView(onRetry: {})
}
