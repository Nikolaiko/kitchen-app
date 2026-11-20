//
//  MigrationsPlan.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 20.11.2026.
//

import Foundation
import SwiftData

enum MigrationsPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV1_1.self, SchemaV2.self]
    }

    static let renamStepTime = MigrationStage.lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV1_1.self)

    static var stages: [MigrationStage] {
        [renamStepTime, ingridientMigrationStep]
    }
}
