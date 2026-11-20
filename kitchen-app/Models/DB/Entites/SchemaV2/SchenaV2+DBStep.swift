//
//  DBStep.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 29.10.2026.
//

import Foundation
import SwiftData

extension SchemaV2 {
    @Model
    final class DBStep {
        var position: Int = 0
        @Attribute(originalName: "timeMinutes")
        var durationMinutes: Int?
        var recipe: DBRecipe?
        var text: String = ""

        init(timeMinutes: Int? = nil, text: String, position: Int) {
            self.durationMinutes = timeMinutes
            self.text = text
            self.position = position
        }
    }
}

extension SchemaV2.DBStep: Identifiable {
    var id: Int { position }
}
