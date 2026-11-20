import SwiftUI
import SwiftData

struct BasedOnPicker: View {
    @Binding var selection: Recipe?
    var excludedRecipe: Recipe? = nil

    @Query(sort: \Recipe.title)
    private var recipes: [Recipe]

    var body: some View {
        Picker("На основе рецепта", selection: $selection) {
            Text("Самостоятельный рецепт")
                .tag(nil as Recipe?)

            ForEach(recipes.filter { $0 != excludedRecipe }) { recipe in
                Text(recipe.title)
                    .tag(recipe as Recipe?)
            }
        }
    }
}
