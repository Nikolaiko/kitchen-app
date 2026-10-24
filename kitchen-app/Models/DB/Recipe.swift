//
//  Recipe.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 13.10.2026.
//

import SwiftData
import UIKit

@Model
final class Recipe {
    var title: String = ""
    var summary: String = ""
    var servings: Int = 2
    var cookingMinutes: Int = 0
    var ingredientsText: String = ""
    var isFavorite: Bool = false
    var createdAt: Date = Date.now
    var difficulty: Difficulty = Difficulty.easy
    var equipment: [String] = []

    var nutrition: Nutrition?

    var thumbnail: UIImage? {
        guard let photo else { return nil }
        if let thumbnailCache, thumbnailCache.source == photo {
            return thumbnailCache.image
        }
        let image = UIImage(data: photo)?.preparingThumbnail(of: CGSize(width: 120, height: 120))
        thumbnailCache = image.map { (photo, $0) }
        return image
    }

    @Attribute(.externalStorage)
    var photo: Data?

    @Transient
    private var thumbnailCache: (source: Data, image: UIImage)? = nil

    @Relationship(deleteRule: .cascade, inverse: \Step.recipe)
    var steps: [Step] = []

    var orderedStep: [Step] {
        steps.sorted { $0.position < $1.position }
    }

    init(title: String = "",
         summary: String = "",
         servings: Int = 2,
         cookingMinutes: Int = 0,
         ingredientsText: String = "",
         equipment: [String] = [],
         difficulty: Difficulty = .easy,
         nutrition: Nutrition? = Nutrition.zero,
         photo: Data? = nil)
    {
        self.title = title
        self.summary = summary
        self.servings = servings
        self.cookingMinutes = cookingMinutes
        self.ingredientsText = ingredientsText
        self.nutrition = nutrition
        self.difficulty = difficulty
        self.photo = photo
        self.equipment = equipment
    }
}
