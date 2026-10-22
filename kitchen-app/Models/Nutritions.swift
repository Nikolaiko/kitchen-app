//
//  Nutritions.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 22.10.2026.
//

import Foundation

struct Nutritions: Codable {
    var calories: Double
    var proteins: Double
    var fats: Double
    var carbohydrates: Double

    static var zero: Nutritions {
        Nutritions(calories: 0, proteins: 0, fats: 0, carbohydrates: 0)
    }
}
