//
//  TagsView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 04.11.2026.
//

import SwiftUI
import SwiftData
import UIKit

struct TagsView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \DBTag.name)
    private var allTags: [DBTag]

    @State
    private var editingTag: DBTag?

    @State
    private var name: String = ""

    @State
    private var color: Color = .blue

    @State
    private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(editingTag == nil ? "Новый тэг" : "Изменить тэг") {
                    TextField("Name", text: $name)
                        .onSubmit(save)

                    ColorPicker("Color", selection: $color, supportsOpacity: false)

                    TagView(name: trimmedName, color: UIColor(color))

                    if hasDublicates {
                        Text("Already taken name!")
                            .foregroundStyle(.secondary)
                    }

                    Button(editingTag == nil ? "Add Tag" : "Edit Tag", action: save)
                        .disabled(!canSave)

                    if editingTag != nil {
                        Button("Cancel edits", action: resetEditor)
                    }

                }

                Section {
                    if allTags.isEmpty {
                        Text("No tags yet")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(allTags) { tag in
                        Button {
                            editingTag = tag
                            name = tag.name
                            color = Color(uiColor: tag.color ?? .systemBlue)
                        } label: {
                            HStack {
                                TagView(name: tag.name, color: tag.color)
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteTag(tag)
                            }
                        }

                    }
                } header: {
                    Text("Все тэги")
                } footer: {
                    Text("Нажмите на тег, чтобы изменить его. При удалении тег исчезнет из всех рецептов, сами рецепты останутся.")
                }
            }
        }
        .navigationTitle("Tags")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done!") { dismiss() }
            }
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasDublicates: Bool {
        allTags.contains {
            $0 != editingTag && $0.name.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && !hasDublicates
    }

    private func save() {
        guard canSave else { return }

        if let tag = editingTag {
            let previousName = tag.name
            let previousColor = tag.color

            tag.name = trimmedName
            tag.color = UIColor(color)

            do {
                try modelContext.save()
                resetEditor()
            } catch {
                tag.name = previousName
                tag.color = previousColor
                errorMessage = error.localizedDescription
            }

        } else {
            let tag = DBTag(name: trimmedName, color: UIColor(color))
            modelContext.insert(tag)
            do {
                try modelContext.save()
                resetEditor()
            } catch {
                modelContext.delete(tag)
                errorMessage = error.localizedDescription
            }
        }
    }

    private func deleteTag(_ tag: DBTag) {
        if editingTag == tag { resetEditor() }
        modelContext.delete(tag)
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetEditor() {
        editingTag = nil
        name = ""
        color = .blue
    }
}

#Preview {
    TagColorTransform.register()
    let container = try! ModelContainer(
        for: DBRecipe.self, DBStep.self, DBTag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    container.mainContext.insert(DBTag(name: "Завтрак", color: .systemOrange))
    container.mainContext.insert(DBTag(name: "Быстро", color: .systemGreen))
    return TagsView().modelContainer(container)
}
