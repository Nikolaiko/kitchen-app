//
//  Schema3_1.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 20.11.2026.
//

import Foundation
import SwiftData

enum SchemaV3_1: VersionedSchema {
    static let versionIdentifier: Schema.Version = Schema.Version(3, 0, 1)

    static var models: [any PersistentModel.Type] {
        [Recipe.self, Step.self, Tag.self, RecipeIngredient.self, Ingredient.self]
    }
}
