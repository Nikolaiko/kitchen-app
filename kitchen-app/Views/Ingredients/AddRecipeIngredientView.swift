import SwiftUI
import SwiftData

struct AddRecipeIngredientView: View {
    let onAdd: (RecipeIngredientDraft) -> Void

    @Environment(\.dismiss)
    private var dismiss

    @Query(sort: \Ingredient.name)
    private var ingredients: [Ingredient]

    @State
    private var selectedIngredient: Ingredient?

    @State
    private var quantityText = ""

    @State
    private var unit = "г"

    @State
    private var comment = ""

    @State
    private var isShowingIngredients = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Ингредиент") {
                    if ingredients.isEmpty {
                        Text("Добавьте ингредиент в справочник, затем выберите его здесь.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Ингредиент", selection: $selectedIngredient) {
                            Text("Выберите ингредиент").tag(nil as Ingredient?)
                            ForEach(ingredients) { ingredient in
                                Text(ingredient.name).tag(ingredient as Ingredient?)
                            }
                        }
                    }

                    Button("Справочник ингредиентов") {
                        isShowingIngredients = true
                    }
                }

                Section {
                    TextField("Количество", text: $quantityText)
                        .keyboardType(.decimalPad)
                    TextField("Единица: г, мл, шт…", text: $unit)
                    TextField("Комментарий, например: просеять", text: $comment, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("В этом рецепте")
                } footer: {
                    Text("Количество должно быть больше нуля. Можно указать дробное число, например 1,5.")
                }
            }
            .navigationTitle("Добавить ингредиент")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить", action: add)
                        .disabled(!canAdd)
                }
            }
            .sheet(isPresented: $isShowingIngredients) {
                IngredientsView()
            }
        }
    }

    private var quantity: Double? {
        Double(quantityText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: "."))
    }

    private var trimmedUnit: String {
        unit.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAdd: Bool {
        guard let selectedIngredient, ingredients.contains(selectedIngredient),
              let quantity, quantity.isFinite, quantity > 0 else { return false }
        return !trimmedUnit.isEmpty
    }

    private func add() {
        guard canAdd, let selectedIngredient, let quantity else { return }
        onAdd(RecipeIngredientDraft(
            ingredient: selectedIngredient,
            quantity: quantity,
            unit: trimmedUnit,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines)
        ))
        dismiss()
    }
}
