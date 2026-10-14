//
//  AddRecipeView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 13.10.2026.
//

import SwiftUI
import SwiftData

struct AddRecipeView: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @State
    private var title: String = ""

    @State
    private var minutes: Int = 30

    @State
    private var ingredients: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название", text: $title)
                Stepper("Время: \(minutes) мин",
                        value: $minutes,
                        in: 5...600,
                        step: 5)
                Section {
                    TextEditor(text: $ingredients)
                        .frame(minHeight: 120)
                } header: {
                    Text("Ингредиенты")
                } footer: {
                    Text("По одному на строку, например: Картофель — 3 шт, кубиками")
                }
            }
            .navigationTitle("Новый рецепт")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить",action: save)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let recipe = Recipe(title: title, cookingMinutes: minutes, ingredientsText: ingredients)
        modelContext.insert(recipe)
        dismiss()
    }
}

#Preview {
    AddRecipeView()
}
