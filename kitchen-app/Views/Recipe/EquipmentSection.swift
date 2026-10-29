import SwiftUI

struct EquipmentSection: View {
    @Binding
    var items: [String]

    @State
    private var newItem: String = ""

    var body: some View {
        Section {
            ForEach(items, id: \.self) { item in
                Text(item)
            }
            .onDelete { items.remove(atOffsets: $0) }

            HStack {
                TextField("Например, духовка", text: $newItem)
                    .onSubmit(add)
                Button("Добавить", systemImage: "plus.circle.fill", action: add)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .disabled(!canAdd)
            }
        } header: {
            Text("Посуда и техника")
        }
    }

    private var trimmedNewItem: String {
        newItem.trimmingCharacters(in: .whitespaces)
    }

    private var canAdd: Bool {
        !trimmedNewItem.isEmpty && !items.contains(trimmedNewItem)
    }

    private func add() {
        guard canAdd else { return }
        items.append(trimmedNewItem)
        newItem = ""
    }
}

#Preview {
    @Previewable @State var items = ["Духовка", "Блендер"]
    Form {
        EquipmentSection(items: $items)
    }
}
