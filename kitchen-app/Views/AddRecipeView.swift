//
//  AddRecipeView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 16.10.2026.
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
    private var summary: String = ""
    @State
    private var minutes: Int = 30
    @State
    private var servings: Int = 1
    @State
    private var isFavorite: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название", text: $title)
                TextField("Описание", text: $summary)
                Stepper("Порции: \(servings)", value: $servings, step: 1)
                Stepper("Время: \(minutes)", value: $minutes, step: 5)
                Toggle(isOn: $isFavorite, label: { Text("Избранное:") })
            }
            .navigationTitle("Добавление")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить", action: save)
                }
            }
        }
    }

    private func save() {
        let recipe = DBRecipe(
            title: title,
            summury: summary,
            servings: servings,
            cookingMinutes: minutes,
            isFavorite: isFavorite)
        modelContext.insert(recipe)
        dismiss()
    }
}

#Preview {
    AddRecipeView()
}
