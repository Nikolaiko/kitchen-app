//
//  DBStep.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 29.10.2026.
//

import Foundation
import SwiftData

extension SchemaV1 {
    @Model
    final class DBStep {
        var position: Int = 0
        var timeMinutes: Int?
        var recipe: DBRecipe?
        var text: String = ""

        init(timeMinutes: Int? = nil, text: String, position: Int) {
            self.timeMinutes = timeMinutes
            self.text = text
            self.position = position
        }
    }
}

extension SchemaV1.DBStep: Identifiable {
    var id: Int { position }
}
