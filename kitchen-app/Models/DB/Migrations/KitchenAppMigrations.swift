//
//  KitchenAppMigrations.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 15.11.2026.
//

import Foundation
import SwiftData

enum KitchenAppMigrations: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV1_1.self, SchemaV2.self, SchemaV3_1.self]
    }

    static let renameStepTimer = MigrationStage.lightweight(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV1_1.self
    )

    static let addingBasedOnToRecipe = MigrationStage.lightweight(
        fromVersion: SchemaV2.self,
        toVersion: SchemaV3_1.self
    )

    static var stages: [MigrationStage] {
        [renameStepTimer, migrateTextIngridients, addingBasedOnToRecipe]
    }
}
