//
//  IngridientView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 13.11.2026.
//

import SwiftUI
import SwiftData

struct IngridientView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \DBIngridient.name)
    private var ingredients: [DBIngridient]

    @State
    private var editingIngredient: DBIngridient?

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

                    ForEach(ingredients) { ingridient in
                        Button {
                            editingIngredient = ingridient
                            name = ingridient.name
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(ingridient.name)
                                    if !ingridient.recipeIngridient.isEmpty {
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
                        .accessibilityLabel("Изменить ингредиент \(ingridient.name)")
                        .swipeActions {
                            Button("Удалить", systemImage: "trash", role: .destructive) {
                                deleteIngredient(ingridient)
                            }
                        }

                    }
                } header: {
                    Text("Все ингредиенты")
                } footer: {
                    Text("Нажмите на ингредиент, чтобы переименовать его во всех рецептах. Удалить можно только ингредиент, который не используется.")
                }

            }
        }
        .navigationTitle("Ингридиенты")
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

            let ingredient = DBIngridient(name: trimmedName)
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

    private func deleteIngredient(_ ingredient: DBIngridient) {
        guard ingredient.recipeIngridient.isEmpty else {
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

    private func resetEditor() {
        editingIngredient = nil
        name = ""
    }
}

#Preview {
    TagColorTransform.register()

    let container = try! ModelContainer(
        for: DBRecipe.self, DBStep.self, DBTag.self, DBRecipeIngridient.self, DBIngridient.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    container.mainContext.insert(DBIngridient(name: "Мука"))
    container.mainContext.insert(DBIngridient(name: "Яйцо"))
    return IngridientView()
        .modelContainer(container)
}
