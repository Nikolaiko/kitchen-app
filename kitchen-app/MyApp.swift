import SwiftUI
import SwiftData

@main struct MyApp: App {
    @State private var store: Result<ModelContainer, Error>

    init() {
        _store = State(initialValue: Self.openStore())
    }

    var body: some Scene {
        WindowGroup {
            switch store {
            case .success(let container):
                ContentView()
                    .modelContainer(container)
            case .failure:
                ModelContainerErrorView {
                    store = Self.openStore()
                }
            }
        }
    }

    private static func openStore() -> Result<ModelContainer, Error> {
        let result = Result { try KitchenStore.make() }
        if case .failure(let error) = result {
            // Полная ошибка остаётся в консоли для разбора на стриме.
            print("Не удалось открыть хранилище: \(error)")
        }
        return result
    }
}
