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
    private var minutes: Int = 30

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название", text: $title)
                Stepper("Время: \(minutes)",
                value: $minutes,
                step: 5)
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
        let recipe = DBRecipe(title: title, cookingMinutes: minutes)
        modelContext.insert(recipe)
        dismiss()
    }
}

#Preview {
    AddRecipeView()
}
