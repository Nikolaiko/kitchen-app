//
//  RecipeIngredient.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 02.11.2026.
//


import SwiftData

@Model
final class RecipeIngredient {
    var quantity: Double
    var unit: String
    var comment: String
    var position: Int

    var recipe: Recipe?
    var ingredient: Ingredient?

    init(
        ingredient: Ingredient,
        quantity: Double,
        unit: String,
        comment: String = "",
        position: Int = 0
    ) {
        self.ingredient = ingredient
        self.quantity = quantity
        self.unit = unit
        self.comment = comment
        self.position = position
    }
}