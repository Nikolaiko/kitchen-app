//
//  Difficulty.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 14.10.2026.
//

import Foundation

enum Difficulty: String, Codable, CaseIterable, Identifiable {

    var id: Self { self }

    case easy
    case medium
    case hard

    var title: String {
        switch self {
        case .easy: "Легко"
        case .medium: "Нормально"
        case .hard: "Заебешься"
        }
    }
}
