//
//  EditRecipeView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 14.10.2026.
//

import SwiftUI
import SwiftData

struct EditRecipeView: View {
    @Bindable
    var recipe: Recipe

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Tag.name)
    private var tags: [Tag]

    @State
    private var newTagName: String = ""

    @State
    private var saveError: String?

    @State
    private var isAddingIngredient = false

    @State
    private var isAddingStep: Bool = false

    @State
    private var newTagColor: Color = .blue

    var body: some View {
        Form {
            TextField("Название", text: $recipe.title)
            Stepper("Время: \(recipe.cookingMinutes) мин",
                    value: $recipe.cookingMinutes,
                    in: 5...600,
                    step: 5)

            BasedOnPicker(
                selection: Binding(
                    get: { recipe.basedOn },
                    set: { updateBasedOn($0) }
                ),
                excludedRecipe: recipe
            )

            Section("Ингредиенты") {
                ForEach(recipe.orderedIngredients) { item in
                    RecipeIngredientRow(
                        name: item.ingredient?.name ?? "Ингредиент удалён",
                        quantity: item.quantity,
                        unit: item.unit,
                        comment: item.comment
                    )
                    .swipeActions {
                        Button("Убрать", systemImage: "minus.circle", role: .destructive) {
                            removeIngredient(item)
                        }
                    }
                }
                Button("Добавить ингредиент", systemImage: "plus.circle.fill") {
                    isAddingIngredient = true
                }
            }

            EquipmentSection(items: $recipe.equipment)

            Section("Теги") {
                ForEach(recipe.tags.sorted { $0.name < $1.name }) { tag in
                    TagView(name: tag.name, color: tag.color)
                        .swipeActions {
                            Button("Убрать", systemImage: "minus.circle", role: .destructive) {
                                removeTag(tag)
                            }
                        }
                }

                if !availableTags.isEmpty {
                    Menu("Выбрать существующий тег", systemImage: "tag") {
                        ForEach(availableTags) { tag in
                            Button(tag.name) { addTag(tag) }
                        }
                    }
                }

                HStack {
                    TextField("Новый тег", text: $newTagName)
                        .onSubmit(addTagByName)
                    ColorPicker(
                        "Цвет нового тега",
                        selection: $newTagColor,
                        supportsOpacity: false
                    )
                    Button("Добавить тег", systemImage: "plus.circle.fill", action: addTagByName)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .disabled(!canAddTag)
                }
            }

            StepsSection(recipe: recipe, onAdd: { isAddingStep = true })

            Picker("Сложность", selection: $recipe.difficulty) {
                ForEach(CurrentSchema.Difficulty.allCases) { format in
                    Text(format.title)
                        .tag(format)
                }
            }
        }
        .navigationTitle("Изменить рецепт")
        .sheet(isPresented: $isAddingStep) {
            AddStepView(recipe: recipe)
        }
        .sheet(isPresented: $isAddingIngredient) {
            AddRecipeIngredientView(onAdd: addIngredient)
        }
        .alert("Не удалось сохранить изменения", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("ОК", role: .cancel) { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
    }

    private func updateBasedOn(_ baseRecipe: Recipe?) {
        let previousRecipe = recipe.basedOn
        recipe.basedOn = baseRecipe
        do {
            try modelContext.save()
        } catch {
            recipe.basedOn = previousRecipe
            saveError = error.localizedDescription
        }
    }

    private var availableTags: [Tag] {
        tags.filter { !recipe.tags.contains($0) }
    }

    private var trimmedTagName: String {
        newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAddTag: Bool {
        !trimmedTagName.isEmpty && !recipe.tags.contains {
            $0.name.localizedCaseInsensitiveCompare(trimmedTagName) == .orderedSame
        }
    }

    private func addTagByName() {
        guard canAddTag else { return }
        if let tag = tags.first(where: {
            $0.name.localizedCaseInsensitiveCompare(trimmedTagName) == .orderedSame
        }) {
            addTag(tag)
        } else {
            addTag(Tag(name: trimmedTagName, color: UIColor(newTagColor)), isNew: true)
        }
    }

    private func addTag(_ tag: Tag, isNew: Bool = false) {
        guard !recipe.tags.contains(tag) else { return }
        if isNew { modelContext.insert(tag) }
        recipe.tags.append(tag)
        do {
            try modelContext.save()
            newTagName = ""
        } catch {
            recipe.tags.removeAll { $0 == tag }
            if isNew { modelContext.delete(tag) }
            saveError = error.localizedDescription
        }
    }

    private func removeTag(_ tag: Tag) {
        let previousTags = recipe.tags
        recipe.tags.removeAll { $0 == tag }
        do {
            try modelContext.save()
        } catch {
            recipe.tags = previousTags
            saveError = error.localizedDescription
        }
    }

    private func addIngredient(_ draft: RecipeIngredientDraft) {
        let position = (recipe.ingredients.map(\.position).max() ?? -1) + 1
        let item = draft.makeModel(position: position)
        modelContext.insert(item)
        recipe.ingredients.append(item)
        do {
            try modelContext.save()
        } catch {
            recipe.ingredients.removeAll { $0 == item }
            modelContext.delete(item)
            saveError = error.localizedDescription
        }
    }

    private func removeIngredient(_ item: RecipeIngredient) {
        recipe.ingredients.removeAll { $0 == item }
        modelContext.delete(item)
        do {
            try modelContext.save()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Query(sort: \Recipe.createdAt) var recipes: [Recipe]

    NavigationStack {
        if let recipe = recipes.first {
            EditRecipeView(recipe: recipe)
        }
    }
}
