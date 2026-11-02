import SwiftUI
import SwiftData

struct IngredientsView: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Ingredient.name)
    private var ingredients: [Ingredient]

    @State
    private var editingIngredient: Ingredient?

    @State
    private var name = ""

    @State
    private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(editingIngredient == nil ? "Новый ингредиент" : "Изменить ингредиент") {
                    TextField("Название", text: $name)
                        .onSubmit(save)

                    if hasDuplicateName {
                        Text("Ингредиент с таким названием уже существует")
                            .foregroundStyle(.secondary)
                    }

                    Button(editingIngredient == nil ? "Добавить ингредиент" : "Сохранить изменения", action: save)
                        .disabled(!canSave)

                    if editingIngredient != nil {
                        Button("Отмена редактирования", action: resetEditor)
                    }
                }

                Section {
                    if ingredients.isEmpty {
                        Text("Пока нет ингредиентов")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(ingredients) { ingredient in
                        Button {
                            editingIngredient = ingredient
                            name = ingredient.name
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(ingredient.name)
                                    if !ingredient.recipeIngredients.isEmpty {
                                        Text("Используется в рецептах")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Изменить ингредиент \(ingredient.name)")
                        .swipeActions {
                            Button("Удалить", systemImage: "trash", role: .destructive) {
                                deleteIngredient(ingredient)
                            }
                        }
                    }
                } header: {
                    Text("Все ингредиенты")
                } footer: {
                    Text("Нажмите на ингредиент, чтобы переименовать его во всех рецептах. Удалить можно только ингредиент, который не используется.")
                }
            }
            .navigationTitle("Ингредиенты")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
            .alert("Ингредиенты", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("ОК", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasDuplicateName: Bool {
        ingredients.contains {
            $0 != editingIngredient && $0.name.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && !hasDuplicateName
    }

    private func save() {
        guard canSave else { return }

        if let ingredient = editingIngredient {
            let previousName = ingredient.name
            ingredient.name = trimmedName
            do {
                try modelContext.save()
                resetEditor()
            } catch {
                ingredient.name = previousName
                errorMessage = error.localizedDescription
            }
        } else {
            let ingredient = Ingredient(name: trimmedName)
            modelContext.insert(ingredient)
            do {
                try modelContext.save()
                resetEditor()
            } catch {
                modelContext.delete(ingredient)
                errorMessage = error.localizedDescription
            }
        }
    }

    private func deleteIngredient(_ ingredient: Ingredient) {
        // В проверке на iOS 27 .deny не остановил удаление при save(), поэтому проверяем связь явно.
        guard ingredient.recipeIngredients.isEmpty else {
            errorMessage = "Ингредиент «\(ingredient.name)» используется в рецептах. Сначала уберите его из их состава."
            return
        }
        if editingIngredient == ingredient { resetEditor() }
        modelContext.delete(ingredient)
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetEditor() {
        editingIngredient = nil
        name = ""
    }
}

#Preview {
    TagColorTransform.register()
    let container = try! ModelContainer(
        for: Recipe.self, Step.self, Tag.self, Ingredient.self, RecipeIngredient.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    container.mainContext.insert(Ingredient(name: "Мука"))
    container.mainContext.insert(Ingredient(name: "Яйцо"))
    return IngredientsView()
        .modelContainer(container)
}
