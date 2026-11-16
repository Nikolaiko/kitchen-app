//
//  SchemaV1.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 15.11.2026.
//

import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static let versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Recipe.self, Step.self, Tag.self, RecipeIngredient.self, Ingredient.self]
    }
}
