import Foundation

extension SchemaV2 {
    enum Difficulty: String, Codable, CaseIterable, Identifiable {
        case easy = "easy"
        // В learning старые записи содержат "medium": сохраняем его после переименования.
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
