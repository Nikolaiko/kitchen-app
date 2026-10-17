import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Query(sort: \DBRecipe.createdAt, order: .reverse)
    private var recipes: [DBRecipe]

    @State
    private var path: [DBRecipe] = []

    @State
    private var isAdding: Bool = false

    var body: some View {
        NavigationStack(path: $path) {
            List(recipes) { recipe in
                Text(recipe.title)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            modelContext.delete(recipe)
                        } label: {
                            Text("Удалить")
                        }

                        Button {
                            path.append(recipe)
                        } label: {
                            Text("Изменить")
                        }
                    }
            }
            .navigationTitle("Рецепты")
            .navigationDestination(for: DBRecipe.self) { recipe in
                EditRecipeView(recipe: recipe)
            }
            .toolbar {
                Button {
                    isAdding = true
                } label: {
                    Text("Добавить")
                }

            }
        }
        .sheet(isPresented: $isAdding) {
            AddRecipeView()
        }

    }
}

#Preview {
    let container = try! ModelContainer(
        for: DBRecipe.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    container.mainContext.insert(DBRecipe(title: "Борщ"))

    return ContentView()
        .modelContainer(container)
}

