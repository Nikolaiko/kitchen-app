//
//  KitchenAppStore.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 20.11.2026.
//

import SwiftData

@MainActor
enum KitchenAppStore {

    static func make(inMemory: Bool = false) throws -> ModelContainer {
        try make(configuration: ModelConfiguration(
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        ))
    }

    static func make(
        schema: any VersionedSchema.Type = CurrentSchema.self,
        migrationPlan: (any SchemaMigrationPlan.Type)? = MigrationsPlan.self,
        configuration: ModelConfiguration
    ) throws -> ModelContainer {
        TagColorTransform.register()

        return try ModelContainer(for: Schema(versionedSchema: schema),
                                  migrationPlan: migrationPlan,
                                  configurations: configuration)
    }
}
