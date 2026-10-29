//
//  AddStepView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 29.10.2026.
//

import Foundation
import SwiftUI
import SwiftData

struct AddStepView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @State
    private var title: String = ""

    @State
    private var minutes: Int = 30

    private let recipe: DBRecipe

    init(recipe: DBRecipe) {
        self.recipe = recipe
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Описание", text: $title)
                Stepper("Время: \(minutes)", value: $minutes, step: 1)
            }
            .navigationTitle("Добавить шаг")
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
        let next = (recipe.steps.map(\.position).max() ?? -1) + 1
        recipe.steps.append(DBStep(text: title, position: next))
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddStepView(recipe: DBRecipe(title: "Омлет"))
        .modelContainer(for: [DBRecipe.self, DBStep.self], inMemory: true)
}
