//
//  Step.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 24.10.2026.
//

import Foundation
import SwiftData

extension SchemaV1_1 {
    @Model
    final class Step {
        var position: Int = 0
        @Attribute(originalName: "timerMinutes")
        var durationMinutes: Int?
        var recipe: Recipe?
        var text: String = ""

        init(durationMinutes: Int? = nil, text: String = "", position: Int) {
            self.durationMinutes = durationMinutes
            self.text = text
            self.position = position
        }
    }
}
