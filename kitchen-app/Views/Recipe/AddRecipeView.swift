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

    @State
    private var title: String = ""

    @State
    private var minutes: Int = 30

    @State
    private var ingredients: String = ""

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
                Section {
                    TextEditor(text: $ingredients)
                        .frame(minHeight: 120)
                } header: {
                    Text("Ингредиенты")
                } footer: {
                    Text("По одному на строку, например: Картофель — 3 шт, кубиками")
                }

                EquipmentSection(items: $equipment)

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
        }
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
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddRecipeView()
        .modelContainer(for: Recipe.self)
}
