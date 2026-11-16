import Foundation
import SwiftData
import Testing
import UIKit
@testable import kitchen_app

@Suite("Миграции пятого стрима", .serialized)
@MainActor
struct KitchenMigrationTests {
    @Test("V1 → V1.1: originalName сохраняет 25 минут")
    func lightweightRenamePreservesTimer() throws {
        try withTemporaryStore { url in
            try autoreleasepool { try writeV1Fixture(at: url) }
            try autoreleasepool {
                let container = try KitchenStore.make(
                    schema: SchemaV1_1.self,
                    migrationPlan: TimerRenamePlan.self,
                    configuration: configuration(at: url)
                )
                let recipes = try container.mainContext.fetch(FetchDescriptor<SchemaV1_1.Recipe>())
                let recipe = try #require(recipes.first { $0.title == "Суп" })
                #expect(recipe.orderedStep.first?.durationMinutes == 25)
                #expect(recipe.orderedStep.last?.durationMinutes == nil)
                #expect(!recipe.ingredientsText.isEmpty)
                #expect(recipe.difficulty == .medium)
            }
        }
    }

    @Test("Без originalName переименованный таймер получает nil")
    func renameWithoutOriginalNameLosesTimer() throws {
        try withTemporaryStore { url in
            try autoreleasepool {
                let container = try KitchenStore.make(
                    schema: RenameDemoV1.self, migrationPlan: nil,
                    configuration: configuration(at: url)
                )
                container.mainContext.insert(RenameDemoV1.Step(timerMinutes: 25))
                try container.mainContext.save()
            }
            try autoreleasepool {
                let container = try KitchenStore.make(
                    schema: RenameDemoV2.self, migrationPlan: nil,
                    configuration: configuration(at: url)
                )
                let steps = try container.mainContext.fetch(FetchDescriptor<RenameDemoV2.Step>())
                #expect(steps.count == 1)
                #expect(steps.first?.durationMinutes == nil)
            }
        }
    }

    @Test("V1 → V2: оба этапа, связи, фото и повторное открытие")
    func fullMigrationAndReopen() throws {
        try withTemporaryStore { url in
            try autoreleasepool { try writeV1Fixture(at: url) }
            try autoreleasepool { try verifyCurrentStore(at: url) }
            try autoreleasepool { try verifyCurrentStore(at: url) }
        }
    }

    @Test("База learning без VersionedSchema обновляется до V2")
    func migrateUnversionedLearningStore() throws {
        try withTemporaryStore { url in
            try autoreleasepool { try writeV1Fixture(at: url, unversioned: true) }
            try autoreleasepool { try verifyCurrentStore(at: url) }
            try autoreleasepool { try verifyCurrentStore(at: url) }
        }
    }

    @Test("Начать обновление можно и с V1.1")
    func migrateFromIntermediateVersion() throws {
        try withTemporaryStore { url in
            try autoreleasepool {
                let container = try KitchenStore.make(
                    schema: SchemaV1_1.self, migrationPlan: nil,
                    configuration: configuration(at: url)
                )
                let recipe = SchemaV1_1.Recipe(
                    title: "Каша", ingredientsText: "Молоко — 0,5 л\n1.5 ст. л. масла",
                    difficulty: .medium
                )
                container.mainContext.insert(recipe)
                recipe.steps = [SchemaV1_1.Step(durationMinutes: 10, text: "Варить", position: 0)]
                try container.mainContext.save()
            }
            try autoreleasepool {
                let container = try KitchenStore.make(configuration: configuration(at: url))
                let recipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())
                let recipe = try #require(recipes.first)
                #expect(recipe.difficulty == .moderate)
                #expect(recipe.orderedStep.first?.durationMinutes == 10)
                let items = recipe.orderedIngredients
                #expect(items.count == 2)
                #expect(items[0].quantity == 0.5 && items[0].unit == "л")
                #expect(items[1].quantity == 1.5 && items[1].unit == "ст. л.")
            }
        }
    }

    @Test("Повторный willMigrate не создаёт дубликаты")
    func repeatedConversionIsSafe() throws {
        let container = try KitchenStore.make(
            schema: SchemaV1_1.self, migrationPlan: nil,
            configuration: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        )
        let context = container.mainContext
        let recipe = SchemaV1_1.Recipe(title: "Тест", ingredientsText: "Соль — по вкусу\nМука — 1/2 стакана")
        context.insert(recipe)
        try context.save()
        guard case let .custom(_, _, before, _) = migrateTextIngridients else {
            Issue.record("Ожидался custom stage")
            return
        }
        let convert = try #require(before)
        try convert(context)
        try convert(context)
        #expect(recipe.ingredientsText.isEmpty)
        let items = recipe.orderedIngredients
        #expect(items.count == 2)
        #expect(items[0].quantity == 0 && items[0].comment == "по вкусу")
        #expect(items[1].quantity == 0 && items[1].comment == "1/2 стакана")
        #expect(try context.fetchCount(FetchDescriptor<SchemaV1_1.Ingredient>()) == 2)
    }

    @Test("Codable: новое имя case сохраняет старое rawValue")
    func codableCaseRename() throws {
        let oldValue = try JSONEncoder().encode(Difficulty.medium)
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(BrokenDifficulty.self, from: oldValue)
        }
        let current = try JSONDecoder().decode(CurrentSchema.Difficulty.self, from: oldValue)
        #expect(current == .moderate)
        #expect(current.rawValue == "medium")
        #expect(current.title == "Нормально")
    }

    @Test("Фабрика изолирует тесты; демоданные заполняются отдельно")
    func containersAreIndependent() throws {
        let first = try KitchenStore.make(inMemory: true)
        let second = try KitchenStore.make(inMemory: true)
        try KitchenSampleData.insert(into: first.mainContext)
        #expect(try first.mainContext.fetchCount(FetchDescriptor<Recipe>()) == 1)
        #expect(try second.mainContext.fetchCount(FetchDescriptor<Recipe>()) == 0)
        let recipe = try #require(first.mainContext.fetch(FetchDescriptor<Recipe>()).first)
        #expect(recipe.steps.count == 2 && recipe.ingredients.count == 3)
    }

    private func writeV1Fixture(at url: URL, unversioned: Bool = false) throws {
        TagColorTransform.register()
        let container = try unversioned
            ? ModelContainer(for: Schema(SchemaV1.models), configurations: configuration(at: url))
            : KitchenStore.make(
                schema: SchemaV1.self, migrationPlan: nil,
                configuration: configuration(at: url)
            )
        let context = container.mainContext
        let flour = SchemaV1.Ingredient(name: "Мука")
        let tag = SchemaV1.Tag(name: "Обед", color: .red)
        let soup = SchemaV1.Recipe(
            title: "Суп", summary: "Старый рецепт", servings: 3, cookingMinutes: 45,
            ingredientsText: "Мука — 1,5 кг, просеять\r\n200 г муки\n \t\nСоль — по вкусу",
            equipment: ["Кастрюля"], difficulty: .medium,
            nutrition: Nutrition(calories: 123, proteins: 4, fats: 5, carbohydrates: 6),
            coverPhoto: Self.photo
        )
        soup.isFavorite = true
        soup.createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        context.insert(flour)
        context.insert(tag)
        context.insert(soup)
        soup.steps = [
            SchemaV1.Step(timerMinutes: 25, text: "Варить", position: 0),
            SchemaV1.Step(text: "Подать", position: 1)
        ]
        soup.tags = [tag]
        soup.ingredients = [SchemaV1.RecipeIngredient(
            ingredient: flour, quantity: 75, unit: "г", comment: "уже добавлен", position: 4
        )]
        context.insert(SchemaV1.Recipe(title: "Пирог", ingredientsText: "МУКА — 250 г", difficulty: .hard))
        context.insert(SchemaV1.Recipe(title: "Пустой", ingredientsText: " \n\t"))
        try context.save()
    }

    private func verifyCurrentStore(at url: URL) throws {
        let container = try KitchenStore.make(configuration: configuration(at: url))
        let context = container.mainContext
        let recipes = try context.fetch(FetchDescriptor<Recipe>())
        #expect(recipes.count == 3)
        let soup = try #require(recipes.first { $0.title == "Суп" })
        #expect(soup.summary == "Старый рецепт" && soup.servings == 3 && soup.isFavorite)
        #expect(soup.createdAt == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(soup.equipment == ["Кастрюля"] && soup.coverPhoto == Self.photo)
        #expect(soup.nutrition == Nutrition(calories: 123, proteins: 4, fats: 5, carbohydrates: 6))
        #expect(soup.difficulty == .moderate)
        #expect(soup.orderedStep.first?.durationMinutes == 25)
        #expect(soup.steps.allSatisfy { $0.recipe === soup })
        let tag = try #require(soup.tags.first)
        #expect(tag.name == "Обед" && tag.color == .red)
        #expect(tag.recipes.contains { $0 === soup })
        let items = soup.orderedIngredients
        #expect(items.map(\.position) == [4, 5, 6, 7])
        #expect(items[0].quantity == 75 && items[0].comment == "уже добавлен")
        #expect(items[1].quantity == 1.5 && items[1].unit == "кг" && items[1].comment == "просеять")
        #expect(items[2].quantity == 200 && items[2].ingredient?.name == "муки")
        #expect(items[3].quantity == 0 && items[3].comment == "по вкусу")
        #expect(items.allSatisfy { $0.recipe === soup && $0.ingredient != nil })
        let pie = try #require(recipes.first { $0.title == "Пирог" })
        #expect(pie.ingredients.first?.ingredient === items[1].ingredient)
        #expect(pie.difficulty == .hard)
        #expect(try context.fetchCount(FetchDescriptor<Ingredient>()) == 3)
        #expect(try context.fetchCount(FetchDescriptor<RecipeIngredient>()) == 5)
        #expect(recipes.first { $0.title == "Пустой" }?.ingredients.isEmpty == true)
    }

    private static var photo: Data { Data(repeating: 0x42, count: 160_000) }

    private func configuration(at url: URL) -> ModelConfiguration {
        ModelConfiguration(url: url, cloudKitDatabase: .none)
    }

    private func withTemporaryStore(_ body: (URL) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try body(directory.appendingPathComponent("migration.store"))
    }
}

private enum TimerRenamePlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self, SchemaV1_1.self] }
    static var stages: [MigrationStage] { [KitchenAppMigrations.renameStepTimer] }
}

private enum BrokenDifficulty: String, Codable {
    case easy, moderate, hard
}

private enum RenameDemoV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Step.self] }
    @Model final class Step {
        var timerMinutes: Int?
        init(timerMinutes: Int?) { self.timerMinutes = timerMinutes }
    }
}

private enum RenameDemoV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [Step.self] }
    @Model final class Step {
        var durationMinutes: Int?
        init(durationMinutes: Int? = nil) { self.durationMinutes = durationMinutes }
    }
}
