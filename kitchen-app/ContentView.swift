import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Recipe.createdAt, order: .reverse)
    private var recipes: [Recipe]

    @Environment(\.modelContext)
    private var modelContext

    @State
    private var isAddingRecipe = false

    @State
    private var isShowingTags = false

    @State
    private var isShowingIngredients = false

    @State
    private var path: [Recipe] = []

    var body: some View {
        NavigationStack(path: $path) {
            List(recipes) { recipe in
                HStack {
                    if let thumbnail = recipe.thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(.rect(cornerRadius: 8))
                    }
                    Text(recipe.title)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Удалить", systemImage: "trash", role: .destructive) {
                        modelContext.delete(recipe)
                    }

                    Button("Изменить", systemImage: "pencil") {
                        path.append(recipe)
                    }
                    .tint(.orange)
                }

            }
            .navigationTitle("Рецепты")
            .navigationDestination(for: Recipe.self) { recipe in
                EditRecipeView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Добавить тэг") {
                        isShowingTags = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Добавить рецепт") {
                        isAddingRecipe = true
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Ингредиенты", systemImage: "carrot") {
                        isShowingIngredients = true
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingRecipe) {
            AddRecipeView()
        }
        .sheet(isPresented: $isShowingTags) {
            TagsView()
        }
        .sheet(isPresented: $isShowingIngredients) {
            IngredientsView()
        }
    }
}

#Preview {
    TagColorTransform.register()
    let container = try! ModelContainer(
        for: Recipe.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    container.mainContext.insert(Recipe(title: "Борщ", servings: 6, cookingMinutes: 90))
    container.mainContext.insert(Recipe(title: "Омлет", servings: 1, cookingMinutes: 10))
    return ContentView()
        .modelContainer(container)
}

