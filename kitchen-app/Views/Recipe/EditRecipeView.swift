//
//  EditRecipeView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 16.10.2026.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditRecipeView: View {

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \DBTag.name)
    private var tags: [DBTag]

    @Bindable
    var recipe: DBRecipe

    @State
    var isImporting: Bool = false

    @State
    var photoItem: PhotosPickerItem?

    @State
    var errorMessage: String?

    @State
    var isAddingStep: Bool = false

    @State
    private var newTagColor: Color = .blue

    @State
    private var newTagName: String = ""

    var body: some View {
        Form {

            TextField("Название", text: $recipe.title)
            TextField("Описание", text: $recipe.summury)

            Picker("Сложность", selection: $recipe.difficulty) {
                ForEach(Difficulty.allCases) { format in
                    Text(format.rawValue)
                        .tag(format)
                }
            }

            Stepper("Порции: \(recipe.servings)",
                    value: $recipe.servings,
                    step: 1)

            Stepper("Время: \(recipe.cookingMinutes)",
                    value: $recipe.cookingMinutes,
                    step: 5)

            Toggle(isOn: $recipe.isFavorite, label: { Text("Избранное:") })

            Section("Ингредиенты") {
                ForEach(recipe.orderedIngredients) { item in
                    RecipeIngridientRowView(
                        name: item.ingridient?.name ?? "Ингредиент удалён",
                        quantity: item.quantity,
                        unit: item.unit,
                        comment: item.comment
                    )
                }
            }


            Section {
                TextEditor(text: $recipe.ingredientsText)
                    .frame(minHeight: 120)
            } header: {
                Text("Ингредиенты")
            } footer: {
                Text("По одному на строку, например: Картофель — 3 шт, кубиками")
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

            Button("Импортировать файл…") { isImporting = true }

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
        }
        .navigationTitle("Изменить рецепт")
        .photosPicker(isPresented: $isImporting, selection: $photoItem, matching: .images)
        .task(id: photoItem) { await load() }
        .sheet(isPresented: $isAddingStep) {
            AddStepView(recipe: recipe)
        }
    }

    private func addTagByName() {
        guard canAddTag else { return }
        if let tag = tags.first(where: {
            $0.name.localizedCaseInsensitiveCompare(trimmedTagName) == .orderedSame
        }) {
            addTag(tag)
        } else {
            addTag(DBTag(name: trimmedTagName, color: UIColor(newTagColor)), isNew: true)
        }
    }

    private func addTag(_ tag: DBTag, isNew: Bool = false) {
        guard !recipe.tags.contains(tag) else { return }
        if isNew { modelContext.insert(tag) }
        recipe.tags.append(tag)
        do {
            try modelContext.save()
            newTagName = ""
        } catch {
            recipe.tags.removeAll { $0 == tag }
            if isNew { modelContext.delete(tag) }
        }
    }

        private func removeTag(_ tag: DBTag) {
            let previousTags = recipe.tags
            recipe.tags.removeAll { $0 == tag }
            do {
                try modelContext.save()
            } catch {
                recipe.tags = previousTags
            }
        }

    private var availableTags: [DBTag] {
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

    private func load() async {
        do {
            recipe.coverPhoto = try await photoItem?.loadTransferable(type: Data.self)
        } catch {
            errorMessage = error.localizedDescription
        }

    }
}

#Preview {
    NavigationStack {
        EditRecipeView(recipe: DBRecipe(title: "Борщ", cookingMinutes: 6))
    }
}
