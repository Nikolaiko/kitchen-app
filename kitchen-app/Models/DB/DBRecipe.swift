//
//  DBRecipe.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 16.10.2026.
//

import Foundation
import SwiftData

@Model
class DBRecipe {
    //ID?
    var title: String
    var summury: String
    var servings: Int
    var cookingMinutes: Int
    var isFavorite: Bool
    var createdAt: Date

    init(title: String = "",
         summury: String = "",
         servings: Int = 1,
         cookingMinutes: Int = 5,
         isFavorite: Bool = false,
         createdAt: Date = .now
    ) {
        self.title = title
        self.summury = summury
        self.servings = servings
        self.cookingMinutes = cookingMinutes
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
}
