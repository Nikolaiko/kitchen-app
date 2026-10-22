//
//  Difficulty.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 22.10.2026.
//

import Foundation

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    var id: Self { self }

    case easy = "easy"
    case normal = "normal"
    case hard = "hard"
}
