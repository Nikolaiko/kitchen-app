import SwiftData

// Промежуточная версия для лёгкой миграции имени таймера.
enum SchemaV1_1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 1, 0)

    static var models: [any PersistentModel.Type] {
        [Recipe.self, Step.self, Tag.self, RecipeIngredient.self, Ingredient.self]
    }
}
