//
//  EditRecipeView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 14.10.2026.
//

import SwiftUI
import SwiftData

struct EditRecipeView: View {
    @Bindable
    var recipe: Recipe

    @State
    private var isAddingStep: Bool = false

    var body: some View {
        Form {
            TextField("Название", text: $recipe.title)
            Stepper("Время: \(recipe.cookingMinutes) мин",
                    value: $recipe.cookingMinutes,
                    in: 5...600,
                    step: 5)

            Section {
                TextEditor(text: $recipe.ingredientsText)
                    .frame(minHeight: 120)
            } header: {
                Text("Ингредиенты")
            } footer: {
                Text("По одному на строку, например: Картофель — 3 шт, кубиками")
            }

            EquipmentSection(items: $recipe.equipment)

            StepsSection(recipe: recipe, onAdd: { isAddingStep = true })

            Picker("Сложность", selection: $recipe.difficulty) {
                ForEach(Difficulty.allCases) { format in
                    Text(format.title)
                        .tag(format)
                }
            }
        }
        .navigationTitle("Изменить рецепт")
        .sheet(isPresented: $isAddingStep) {
            AddStepView(recipe: recipe)
        }
    }
}

#Preview {
    NavigationStack {
        EditRecipeView(recipe: Recipe(title: "Борщ", servings: 6, cookingMinutes: 90))
    }
}
