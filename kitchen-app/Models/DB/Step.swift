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
    var timerMinutes: Int?
    var recipe: Recipe?
    var text: String = ""

    init(timerMinutes: Int? = nil, text: String = "", position: Int) {
        self.timerMinutes = timerMinutes
        self.text = text
        self.position = position
    }
}
