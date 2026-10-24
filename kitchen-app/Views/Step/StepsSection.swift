import SwiftUI
import SwiftData

struct StepsSection: View {
    let recipe: Recipe

    let onAdd: () -> Void

    var body: some View {
        Section {
            ForEach(Array(recipe.orderedStep.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .firstTextBaseline) {
                    Text("\(index + 1).")
                        .foregroundStyle(.secondary)
                    Text(step.text)
                    Spacer()
                    if step.timeMinutes > 0 {
                        Text("\(step.timeMinutes) мин")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button("Добавить шаг", systemImage: "plus.circle.fill", action: onAdd)
        } header: {
            Text("Шаги")
        }
    }
}

#Preview {
    let recipe = Recipe(title: "Омлет")
    recipe.steps.append(Step(timeMinutes: 2, text: "Взбить яйца с молоком", position: 0))
    recipe.steps.append(Step(timeMinutes: 5, text: "Жарить под крышкой", position: 1))
    return Form {
        StepsSection(recipe: recipe, onAdd: {})
    }
    .modelContainer(for: [Recipe.self, Step.self], inMemory: true)
}
