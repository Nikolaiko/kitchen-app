import SwiftUI
import SwiftData
import UIKit

struct TagsView: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Tag.name)
    private var tags: [Tag]

    @State
    private var editingTag: Tag?

    @State
    private var name = ""

    @State
    private var color: Color = .blue

    @State
    private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(editingTag == nil ? "Новый тег" : "Изменить тег") {
                    TextField("Название", text: $name)
                        .onSubmit(save)

                    ColorPicker("Цвет", selection: $color, supportsOpacity: false)

                    if !trimmedName.isEmpty {
                        TagView(name: trimmedName, color: UIColor(color))
                    }

                    if hasDuplicateName {
                        Text("Тег с таким названием уже существует")
                            .foregroundStyle(.secondary)
                    }

                    Button(editingTag == nil ? "Добавить тег" : "Сохранить изменения", action: save)
                        .disabled(!canSave)

                    if editingTag != nil {
                        Button("Отмена редактирования", action: resetEditor)
                    }
                }

                Section {
                    if tags.isEmpty {
                        Text("Пока нет тегов")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(tags) { tag in
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
                        .accessibilityLabel("Изменить тег \(tag.name)")
                        .swipeActions {
                            Button("Удалить", systemImage: "trash", role: .destructive) {
                                deleteTag(tag)
                            }
                        }
                    }
                } header: {
                    Text("Все теги")
                } footer: {
                    Text("Нажмите на тег, чтобы изменить его. При удалении тег исчезнет из всех рецептов, сами рецепты останутся.")
                }
            }
            .navigationTitle("Теги")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
            .alert("Не удалось сохранить изменения", isPresented: Binding(
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
        tags.contains {
            $0 != editingTag && $0.name.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && !hasDuplicateName
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
            let tag = Tag(name: trimmedName, color: UIColor(color))
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

    private func deleteTag(_ tag: Tag) {
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
        for: Recipe.self, Step.self, Tag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    container.mainContext.insert(Tag(name: "Завтрак", color: .systemOrange))
    container.mainContext.insert(Tag(name: "Быстро", color: .systemGreen))
    return TagsView()
        .modelContainer(container)
}
