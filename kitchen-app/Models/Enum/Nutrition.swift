//
//  Nutrition.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 14.10.2026.
//

import Foundation

struct Nutrition: Codable, Hashable {
    let calories: Double
    let proteins: Double
    let fats: Double
    let carbohydrates: Double

    static var zero: Nutrition {
        Nutrition(calories: 0, proteins: 0, fats: 0, carbohydrates: 0)
    }
}
