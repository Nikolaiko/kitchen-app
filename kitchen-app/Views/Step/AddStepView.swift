//
//  AddStepView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 24.10.2026.
//

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

    private let recipe: Recipe

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Описание", text: $title)
                Stepper(": \(minutes) мин",
                        value: $minutes,
                        in: 5...600,
                        step: 5)
            }
            .navigationTitle("Новый шаг")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить",action: save)
                }
            }
        }
    }

    private func save() {
        let next = (recipe.steps.map(\.position).max() ?? -1) + 1
        recipe.steps.append(Step(timeMinutes: minutes, text: title, position: next))
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddStepView(recipe: Recipe(title: "Омлет"))
        .modelContainer(for: [Recipe.self, Step.self], inMemory: true)
}
