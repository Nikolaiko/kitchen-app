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

                Picker("Сложность", selection: $difficulty) {
                    ForEach(Difficulty.allCases) { format in
                        Text(format.rawValue)
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
        let recipe = Recipe(title: title, cookingMinutes: minutes, ingredientsText: ingredients, equipment: equipment, difficulty: difficulty, photo: data)
        modelContext.insert(recipe)
        dismiss()
    }
}

#Preview {
    AddRecipeView()
        .modelContainer(for: Recipe.self)
}
