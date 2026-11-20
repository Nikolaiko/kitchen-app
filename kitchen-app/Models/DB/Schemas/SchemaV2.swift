//
//  SchemaV2.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 20.11.2026.
//

import Foundation
import SwiftData

enum SchemaV2: VersionedSchema {
    static let versionIdentifier: Schema.Version = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [DBRecipe.self, DBStep.self, DBTag.self, DBRecipeIngridient.self, DBIngridient.self]
    }
}

