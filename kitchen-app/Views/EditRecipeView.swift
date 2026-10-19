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
            TextField("Описание", text: $recipe.summury)

            Stepper("Порции: \(recipe.servings)",
                    value: $recipe.servings,
                    step: 1)

            Stepper("Время: \(recipe.cookingMinutes)",
                    value: $recipe.cookingMinutes,
                    step: 5)

            Toggle(isOn: $recipe.isFavorite, label: { Text("Избранное:") })
        }
        .navigationTitle("Изменить рецепт")
    }
}

#Preview {
    NavigationStack {
        EditRecipeView(recipe: DBRecipe(title: "Борщ", cookingMinutes: 6))
    }
}
