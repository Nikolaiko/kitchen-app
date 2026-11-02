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
        .modelContainer(for: [
            Recipe.self,
            Step.self,
            Tag.self,
            Ingredient.self,
            RecipeIngredient.self
        ])
    }
}
