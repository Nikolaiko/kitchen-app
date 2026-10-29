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

        modelContext.insert(draft)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddRecipeView()
}
