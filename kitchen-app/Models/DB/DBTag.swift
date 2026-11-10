//
//  DBTag.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 04.11.2026.
//

import SwiftData
import UIKit

@Model
final class DBTag {
    var name: String
    var recipes: [DBRecipe]

    @Attribute(.transformable(by: TagColorTransform.self))
    var color: UIColor?

    init(name: String, recipes: [DBRecipe] = [], color: UIColor? = .systemBlue) {
        self.name = name
        self.recipes = recipes
        self.color = color
    }
}
