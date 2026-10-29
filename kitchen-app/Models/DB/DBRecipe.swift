//
//  DBRecipe.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 16.10.2026.
//

import UIKit
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

    var ingredientsText: String = ""
    var equipment: [String] = []
    var nutritions: Nutritions?
    var difficulty: Difficulty = Difficulty.easy

    @Attribute(.externalStorage)
    var coverPhoto: Data?

    @Transient
    private var thumbnailCache: (source: Data, image: UIImage)? = nil

    var thumbnail: UIImage? {
        guard let coverPhoto else { return nil }
        if let thumbnailCache, thumbnailCache.source == coverPhoto {
            return thumbnailCache.image
        }
        let image = UIImage(data: coverPhoto)?.preparingThumbnail(of: CGSize(width: 120, height: 120))
        thumbnailCache = image.map { (coverPhoto, $0) }
        return image
    }

    @Relationship(deleteRule: .cascade, inverse: \DBStep.recipe)
    var steps: [DBStep] = []

    var orderedSteps: [DBStep] {
        steps.sorted { $0.position < $1.position }
    }

    init(title: String = "",
         summury: String = "",
         servings: Int = 1,
         cookingMinutes: Int = 5,
         isFavorite: Bool = false,
         createdAt: Date = .now,
         coverPhoto: Data? = nil,
         difficulty: Difficulty = .easy,
         nutritions: Nutritions? = .zero,
         ingredientsText: String = "",
         equipment: [String] = []
    ) {
        self.title = title
        self.summury = summury
        self.servings = servings
        self.cookingMinutes = cookingMinutes
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.coverPhoto = coverPhoto
        self.difficulty = difficulty
        self.nutritions = nutritions
        self.ingredientsText = ingredientsText
        self.equipment = equipment
    }
}
