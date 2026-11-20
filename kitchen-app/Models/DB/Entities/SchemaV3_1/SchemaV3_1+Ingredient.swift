//
//  Ingredient.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 02.11.2026.
//


import SwiftData

extension SchemaV3_1 {
    @Model
    final class Ingredient {
        var name: String

        @Relationship(deleteRule: .deny, inverse: \RecipeIngredient.ingredient)
        var recipeIngredients: [RecipeIngredient] = []

        init(name: String) {
            self.name = name
        }
    }
}
