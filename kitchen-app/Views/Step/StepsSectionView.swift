//
//  StepsSectionView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 29.10.2026.
//

import SwiftUI
import SwiftData

struct StepsSection: View {
    let recipe: DBRecipe

    let onAdd: () -> Void

    @Environment(\.modelContext)
    private var modelContext: ModelContext

    var body: some View {
        Section {
            ForEach(Array(recipe.orderedSteps.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .firstTextBaseline) {
                    Text("\(index + 1).")
                        .foregroundStyle(.secondary)
                    Text(step.text)
                    Spacer()
                    if let minutes = step.timeMinutes {
                        Text("\(minutes) мин")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                /*
                let ordered = recipe.orderedStep
                for i in offsets {
                    let step = ordered[i]
                    recipe.steps.removeAll { $0 == step }   // шаг пропал с экрана, но остался в базе
                }
                try? modelContext.save()
                */
                let ordered = recipe.orderedSteps
                for i in offsets {
                    recipe.steps.removeAll { $0 == ordered[i] }
                    modelContext.delete(ordered[i])
                }
                try? modelContext.save()
            }
            .onMove { offsets, index in
                 //recipe.steps.move(fromOffsets: offsets, toOffset: index)
                var steps = recipe.orderedSteps
                steps.move(fromOffsets: offsets, toOffset: index)
                for (index, step) in steps.enumerated() { step.position = index }
                try? modelContext.save()
            }

            Button("Добавить шаг", systemImage: "plus.circle.fill", action: onAdd)
        } header: {
            Text("Шаги")
        }
    }
}

//#Preview {
//    let recipe = DBRecipe(title: "Омлет")
//    recipe.steps.append(DBStep(timerMinutes: 2, text: "Взбить яйца с молоком", position: 0))
//    recipe.steps.append(DBStep(text: "Посолить", position: 1))
//    return Form {
//        StepsSection(recipe: recipe, onAdd: {})
//    }
//    .modelContainer(for: [DBRecipe.self, DBStep.self], inMemory: true)
//}
