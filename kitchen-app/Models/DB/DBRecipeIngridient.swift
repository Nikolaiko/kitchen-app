//
//  DBRecipeIngridient.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 13.11.2026.
//

import Foundation
import SwiftData

@Model
final class DBRecipeIngridient {
    var quantity: Double
    var unit: String
    var comment: String
    var position: Int

    var recipe: DBRecipe?
    var ingridient: DBIngridient?

    init(
        ingridient: DBIngridient,
        quantity: Double,
         unit: String,
         comment: String,
         position: Int,
    ) {
        self.ingridient = ingridient
        self.quantity = quantity
        self.unit = unit
        self.comment = comment
        self.position = position
    }
}
