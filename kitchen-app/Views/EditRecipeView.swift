//
//  EditRecipeView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 16.10.2026.
//

import SwiftUI

struct EditRecipeView: View {

    @Bindable
    var recipe: DBRecipe

    var body: some View {
        Form {
            TextField("Название", text: $recipe.title)
            Stepper("Время: \(recipe.cookingMinutes)",
            value: $recipe.cookingMinutes,
            step: 5)
        }
        .navigationTitle("Изменить рецепт")
    }
}

#Preview {
    NavigationStack {
        EditRecipeView(recipe: DBRecipe(title: "Борщ", cookingMinutes: 6))
    }
}
