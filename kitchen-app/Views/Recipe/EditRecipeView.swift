//
//  EditRecipeView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 16.10.2026.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditRecipeView: View {

    @Bindable
    var recipe: DBRecipe

    @State
    var isImporting: Bool = false

    @State
    var photoItem: PhotosPickerItem?

    @State
    var errorMessage: String?

    @State
    var isAddingStep: Bool = false

    var body: some View {
        Form {
            
            TextField("Название", text: $recipe.title)
            TextField("Описание", text: $recipe.summury)

            Picker("Сложность", selection: $recipe.difficulty) {
                ForEach(Difficulty.allCases) { format in
                    Text(format.rawValue)
                        .tag(format)
                }
            }

            Stepper("Порции: \(recipe.servings)",
                    value: $recipe.servings,
                    step: 1)

            Stepper("Время: \(recipe.cookingMinutes)",
                    value: $recipe.cookingMinutes,
                    step: 5)

            Toggle(isOn: $recipe.isFavorite, label: { Text("Избранное:") })

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

            Button("Импортировать файл…") { isImporting = true }

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
        }
        .navigationTitle("Изменить рецепт")
        .photosPicker(isPresented: $isImporting, selection: $photoItem, matching: .images)
        .task(id: photoItem) { await load() }
        .sheet(isPresented: $isAddingStep) {
            AddStepView(recipe: recipe)
        }
    }

    private func load() async {
        do {
            recipe.coverPhoto = try await photoItem?.loadTransferable(type: Data.self)
        } catch {
            errorMessage = error.localizedDescription
        }

    }
}

#Preview {
    NavigationStack {
        EditRecipeView(recipe: DBRecipe(title: "Борщ", cookingMinutes: 6))
    }
}
