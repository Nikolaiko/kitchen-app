//
//  Difficulty.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 14.10.2026.
//

import Foundation

enum Difficulty: String, Codable, CaseIterable, Identifiable {

    var id: Self { self }

    case easy = "Легко"
    case normal = "Нормально"
    case hard = "Заебешься"
}
