//
//  AddRecipeView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 13.10.2026.
//

import SwiftUI
import SwiftData
import PhotosUI
internal import UniformTypeIdentifiers

struct AddRecipeView: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Tag.name)
    private var tags: [Tag]

    // До сохранения держим выбор отдельно: связь с сохранённым тегом
    // может добавить черновик рецепта в контекст через inverse.
    @State
    private var selectedTags: [Tag] = []

    @State
    private var newTagName: String = ""

    @State
    private var title: String = ""

    @State
    private var minutes: Int = 30

    @State
    private var ingredients: String = ""

    @State
    private var ingredientDrafts: [RecipeIngredientDraft] = []

    @State
    private var isAddingIngredient = false

    @State
    private var equipment: [String] = []

    @State
    private var difficulty: Difficulty = .easy

    @State
    private var isImporting: Bool = false

    @State
    private var errorMessage: String?

    @State
    private var data: Data?

    @State
    private var newTagColor: Color = .blue

    @State private var photoItem: PhotosPickerItem?

    // Шаги копятся в черновике, в контекст он попадает только в save()
    @State
    private var draft = Recipe()

    @State
    private var isAddingStep: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название", text: $title)
                Stepper("Время: \(minutes) мин",
                        value: $minutes,
                        in: 5...600,
                        step: 5)
                Section("Ингредиенты") {
                    ForEach(ingredientDrafts) { item in
                        RecipeIngredientRow(
                            name: item.ingredient.name,
                            quantity: item.quantity,
                            unit: item.unit,
                            comment: item.comment
                        )
                        .swipeActions {
                            Button("Убрать", systemImage: "minus.circle", role: .destructive) {
                                ingredientDrafts.removeAll { $0.id == item.id }
                            }
                        }
                    }
                    Button("Добавить ингредиент", systemImage: "plus.circle.fill") {
                        isAddingIngredient = true
                    }
                }

                Section {
                    TextEditor(text: $ingredients)
                        .frame(minHeight: 120)
                } header: {
                    Text("Ингредиенты текстом")
                } footer: {
                    Text("По одному на строку, например: Картофель — 3 шт, кубиками")
                }

                EquipmentSection(items: $equipment)

                Section("Теги") {
                    ForEach(selectedTags.sorted { $0.name < $1.name }) { tag in
                        TagView(name: tag.name, color: tag.color)
                            .swipeActions {
                                Button("Убрать", systemImage: "minus.circle", role: .destructive) {
                                    selectedTags.removeAll { $0 == tag }
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

                StepsSection(recipe: draft, onAdd: { isAddingStep = true })

                Picker("Сложность", selection: $difficulty) {
                    ForEach(Difficulty.allCases) { format in
                        Text(format.title)
                            .tag(format)
                    }
                }

                Button("Импортировать файл…") { isImporting = true }

                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
            .navigationTitle("Новый рецепт")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить",action: save)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .photosPicker(isPresented: $isImporting, selection: $photoItem, matching: .images)
            .task(id: photoItem) { await load() }
            .sheet(isPresented: $isAddingStep) {
                AddStepView(recipe: draft)
            }
            .sheet(isPresented: $isAddingIngredient) {
                AddRecipeIngredientView { ingredientDrafts.append($0) }
            }
        }
    }

    private var availableTags: [Tag] {
        tags.filter { !selectedTags.contains($0) }
    }

    private var trimmedTagName: String {
        newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAddTag: Bool {
        !trimmedTagName.isEmpty && !selectedTags.contains {
            $0.name.localizedCaseInsensitiveCompare(trimmedTagName) == .orderedSame
        }
    }

    private func addTagByName() {
        guard canAddTag else { return }
        let tag = tags.first {
            $0.name.localizedCaseInsensitiveCompare(trimmedTagName) == .orderedSame
        } ?? Tag(name: trimmedTagName, color: UIColor(newTagColor))
        addTag(tag)
    }

    private func addTag(_ tag: Tag) {
        guard !selectedTags.contains(tag) else { return }
        selectedTags.append(tag)
        newTagName = ""
    }

    private func load() async {
        do {
            data = try await photoItem?.loadTransferable(type: Data.self)
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save() {
        draft.title = title
        draft.cookingMinutes = minutes
        draft.ingredientsText = ingredients
        draft.equipment = equipment
        draft.difficulty = difficulty
        draft.coverPhoto = data
        modelContext.insert(draft)
        draft.tags = selectedTags
        draft.ingredients = ingredientDrafts.enumerated().map { position, item in
            item.makeModel(position: position)
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    TagColorTransform.register()
    let container = try! ModelContainer(
        for: Recipe.self, Step.self, Tag.self, Ingredient.self, RecipeIngredient.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    container.mainContext.insert(Ingredient(name: "Мука"))
    return AddRecipeView()
        .modelContainer(container)
}
