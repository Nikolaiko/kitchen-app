//
//  Ефп.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 01.11.2026.
//

import UIKit
import SwiftData

@Model
final class Tag {
    var name: String

    var recipes: [Recipe]

    @Attribute(.transformable(by: TagColorTransform.self))
    var color: UIColor?

    init(name: String, recipes: [Recipe] = [], color: UIColor? = .systemBlue) {
        self.name = name
        self.recipes = recipes
        self.color = color
    }
}
