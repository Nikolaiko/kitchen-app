import SwiftData
import SwiftUI

@MainActor
enum KitchenSampleData {
    static func insert(into context: ModelContext) throws {
        let recipe = Recipe(
            title: "Омлет",
            summary: "Быстрый завтрак на сковороде",
            servings: 2,
            cookingMinutes: 15,
            equipment: ["Сковорода", "Венчик"],
            difficulty: .moderate
        )
        recipe.isFavorite = true
        let eggs = Ingredient(name: "Яйцо")
        let milk = Ingredient(name: "Молоко")
        let salt = Ingredient(name: "Соль")
        let tag = Tag(name: "Завтрак", color: .systemOrange)
        context.insert(recipe)
        context.insert(eggs)
        context.insert(milk)
        context.insert(salt)
        context.insert(tag)
        recipe.tags = [tag]
        recipe.steps = [
            Step(durationMinutes: 2, text: "Взбить яйца с молоком", position: 0),
            Step(durationMinutes: 5, text: "Готовить под крышкой", position: 1)
        ]
        recipe.ingredients = [
            RecipeIngredient(ingredient: eggs, quantity: 3, unit: "шт", comment: "", position: 0),
            RecipeIngredient(ingredient: milk, quantity: 100, unit: "мл", comment: "", position: 1),
            RecipeIngredient(ingredient: salt, quantity: 0, unit: "", comment: "по вкусу", position: 2)
        ]
        try context.save()
    }
}

struct KitchenPreview: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let container = try KitchenStore.make(inMemory: true)
        try KitchenSampleData.insert(into: container.mainContext)
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self {
        .modifier(KitchenPreview())
    }
}
