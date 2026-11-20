//
//  DBIngridient.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 13.11.2026.
//

import SwiftData

extension SchemaV1_1 {
    @Model
    final class DBIngridient {
        var name: String

        @Relationship(deleteRule: .deny, inverse: \DBRecipeIngridient.ingridient)
        var recipeIngridient: [DBRecipeIngridient] = []

        init(name: String) {
            self.name = name
        }
    }
}
