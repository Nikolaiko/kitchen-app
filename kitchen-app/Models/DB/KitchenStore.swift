import SwiftData

@MainActor
enum KitchenStore {
    // Каждый вызов создаёт новый контейнер: тесты не разделяют состояние.
    static func make(inMemory: Bool = false) throws -> ModelContainer {
        try make(configuration: ModelConfiguration(
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        ))
    }

    // Позволяет тестам открыть отдельный файл в конкретной версии схемы.
    static func make(
        schema: any VersionedSchema.Type = CurrentSchema.self,
        migrationPlan: (any SchemaMigrationPlan.Type)? = KitchenAppMigrations.self,
        configuration: ModelConfiguration
    ) throws -> ModelContainer {
        TagColorTransform.register()
        return try ModelContainer(
            for: Schema(versionedSchema: schema),
            migrationPlan: migrationPlan,
            configurations: configuration
        )
    }
}
