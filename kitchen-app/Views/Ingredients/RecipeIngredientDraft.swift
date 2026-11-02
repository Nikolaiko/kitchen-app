import Foundation

// Значение формы, а не @Model: выбор ингредиента не меняет его обратную связь.
struct RecipeIngredientDraft: Identifiable {
    let id = UUID()
    let ingredient: Ingredient
    let quantity: Double
    let unit: String
    let comment: String

    func makeModel(position: Int) -> RecipeIngredient {
        RecipeIngredient(
            ingredient: ingredient,
            quantity: quantity,
            unit: unit,
            comment: comment,
            position: position
        )
    }
}
