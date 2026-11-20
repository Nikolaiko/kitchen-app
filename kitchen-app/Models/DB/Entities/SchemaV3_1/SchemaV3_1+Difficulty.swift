import Foundation

extension SchemaV3_1 {
    enum Difficulty: String, Codable, CaseIterable, Identifiable {
        case easy = "easy"
        case moderate = "medium"
        case hard = "hard"

        var id: Self { self }

        var title: String {
            switch self {
            case .easy: "Легко"
            case .moderate: "Нормально"
            case .hard: "Заебешься"
            }
        }
    }
}
