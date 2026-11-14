import SwiftUI
import SwiftData

@main struct MyApp: App {

    init() {
        TagColorTransform.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DBRecipe.self, DBStep.self, DBTag.self, DBRecipeIngridient.self, DBIngridient.self])
    }
}
