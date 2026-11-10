//
//  AddRecipeView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 16.10.2026.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddRecipeView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \DBTag.name)
    private var tags: [DBTag]

    @State
    private var selectedTags: [DBTag] = []

    @State
    private var title: String = ""
    @State
    private var summary: String = ""
    @State
    private var minutes: Int = 30
    @State
    private var servings: Int = 1
    @State
    private var isFavorite: Bool = false
    @State
    private var difficulty: Difficulty = .easy
    @State
    private var ingredientsText: String = ""
    @State
    private var equipment: [String] = []
    @State
    private var data: Data?
    @State
    var isImporting: Bool = false

    @State
    var photoItem: PhotosPickerItem?

    @State
    var errorMessage: String?

    @State
    var isAddingStep: Bool = false

    @State
    var draft: DBRecipe = DBRecipe()

    @State
    private var newTagColor: Color = .blue

    @State
    private var newTagName: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название", text: $title)

                TextField("Описание", text: $summary)

                Stepper("Порции: \(servings)", value: $servings, step: 1)

                Stepper("Время: \(minutes)", value: $minutes, step: 5)

                Toggle(isOn: $isFavorite, label: { Text("Избранное:") })

                Picker("Сложность", selection: $difficulty) {
                    ForEach(Difficulty.allCases) { format in
                        Text(format.rawValue)
                            .tag(format)
                    }
                }

                Section {
                    TextEditor(text: $ingredientsText)
                        .frame(minHeight: 120)
                } header: {
                    Text("Ингредиенты")
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

                Button("Импортировать файл…") { isImporting = true }

                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
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
            .photosPicker(isPresented: $isImporting, selection: $photoItem, matching: .images)
            .task(id: photoItem) { await load() }
            .sheet(isPresented: $isAddingStep) {
                AddStepView(recipe: draft)
            }
        }
    }

    private func addTagByName() {
        guard canAddTag else { return }
        let tag = tags.first {
            $0.name.localizedCaseInsensitiveCompare(trimmedTagName) == .orderedSame
        } ?? DBTag(name: trimmedTagName, color: UIColor(newTagColor))

        addTag(tag)
    }

    private func addTag(_ tag: DBTag) {
        guard !selectedTags.contains(tag) else { return }
        selectedTags.append(tag)
        newTagName = ""
    }

    private var availableTags: [DBTag] {
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

    private func load() async {
        do {
            data = try await photoItem?.loadTransferable(type: Data.self)
        } catch {
            errorMessage = error.localizedDescription
        }

    }

    private func save() {
        draft.title = title
        draft.summury = summary
        draft.servings = servings
        draft.cookingMinutes = minutes
        draft.isFavorite = isFavorite
        draft.coverPhoto = data
        draft.difficulty = difficulty
        draft.ingredientsText = ingredientsText
        draft.equipment = equipment
        draft.coverPhoto = data
        draft.tags = selectedTags

        modelContext.insert(draft)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddRecipeView()
}
