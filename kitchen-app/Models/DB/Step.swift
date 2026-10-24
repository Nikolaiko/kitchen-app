//
//  Step.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 24.10.2026.
//

import Foundation
import SwiftData

@Model
final class Step {
    var position: Int = 0
    var timeMinutes: Int = 0
    var recipe: Recipe?
    var text: String = ""

    init(timeMinutes: Int = 0, text: String = "", position: Int) {
        self.timeMinutes = timeMinutes
        self.text = text
        self.position = position
    }
}
