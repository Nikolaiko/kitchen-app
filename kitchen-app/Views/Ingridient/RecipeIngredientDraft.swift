//
//  RecipeIngredientDraft.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 13.11.2026.
//


import Foundation

// Значение формы, а не @Model: выбор ингредиента не меняет его обратную связь.
struct RecipeIngredientDraft: Identifiable {
    let id = UUID()
    let ingredient: DBIngridient
    let quantity: Double
    let unit: String
    let comment: String

    func makeModel(position: Int) -> DBRecipeIngridient {
        DBRecipeIngridient(
            ingridient: ingredient,
            quantity: quantity,
            unit: unit,
            comment: comment,
            position: position
        )
    }
}
