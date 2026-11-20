//
//  IngridientMigrationStep.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 20.11.2026.
//

import Foundation
import SwiftData

let ingridientMigrationStep = MigrationStage.custom(
    fromVersion: SchemaV1_1.self,
    toVersion: SchemaV2.self) { context in

        let recipes = try context.fetch(FetchDescriptor<SchemaV1_1.DBRecipe>())
        let ingridients = try context.fetch(FetchDescriptor<SchemaV1_1.DBIngridient>())

        let amountExpression = try NSRegularExpression(
            pattern: #"^([0-9]+(?:[.,][0-9]+)?)\s*([^\d,]*?)(?:,\s*(.*))?$"#
        )
        let quantityFirstExpression = try NSRegularExpression(
            pattern: #"^([0-9]+(?:[.,][0-9]+)?)\s*((?:ст\.|ч\.)\s*л\.|[^\s\d,]+)\s+([^,]+?)(?:,\s*(.*))?$"#,
            options: .caseInsensitive
        )

        var ingByName : [String : SchemaV1_1.DBIngridient] = [:]
        for ing in ingridients {
            let key = ingredientNameKey(ing.name)
            if ingByName[key] == nil {
                ingByName[key] = ing
            }
        }

        for recipe in recipes {
            var position = (recipe.ingredients.map(\.position).max() ?? -1) + 1

            for line in recipe.ingredientsText.split(whereSeparator: \.isNewline) {
                guard let parsed = ParsedTextIngredient(
                    line: String(line),
                    amountExpression: amountExpression,
                    quantityFirstExpression: quantityFirstExpression
                ) else { continue }

                let key = ingredientNameKey(parsed.name)
                let ingridient: SchemaV1_1.DBIngridient
                if let existing = ingByName[key] {
                    ingridient = existing
                } else {
                    ingridient = SchemaV1_1.DBIngridient(name: parsed.name)
                    context.insert(ingridient)
                    ingByName[key] = ingridient
                }

                let item = SchemaV1_1.DBRecipeIngridient(
                    ingridient: ingridient,
                    quantity: parsed.quantity,
                    unit: parsed.unit,
                    comment: parsed.comment,
                    position: position
                )

                context.insert(item)
                recipe.ingredients.append(item)
                position += 1
            }

            recipe.ingredientsText = ""
        }

        try context.save()

    } didMigrate: { context in

    }

private func ingredientNameKey(_ name: String) -> String {
    name.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased()
}

private struct ParsedTextIngredient {
    let name: String
    let quantity: Double
    let unit: String
    let comment: String

    init?(
        line: String,
        amountExpression: NSRegularExpression,
        quantityFirstExpression: NSRegularExpression
    ) {
        let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }

        // Второй формат: «200 г муки, просеять» или «1,5 ст. л. масла».
        if let match = quantityFirstExpression.firstMatch(
            in: text, range: NSRange(text.startIndex..., in: text)
        ), let amountRange = Range(match.range(at: 1), in: text),
           let amount = Double(text[amountRange].replacingOccurrences(of: ",", with: ".")),
           amount.isFinite, amount > 0,
           let unitRange = Range(match.range(at: 2), in: text),
           let nameRange = Range(match.range(at: 3), in: text),
           !text[nameRange].trimmingCharacters(in: .whitespaces).isEmpty {
            name = String(text[nameRange]).trimmingCharacters(in: .whitespaces)
            quantity = amount
            unit = String(text[unitRange]).trimmingCharacters(in: .whitespaces)
            comment = Range(match.range(at: 4), in: text)
                .map { String(text[$0]).trimmingCharacters(in: .whitespaces) } ?? ""
            return
        }

        // Формат из подсказки в форме: «Картофель — 3 шт, кубиками».
        guard let separator = text.range(of: #"\s+[—–-]\s*"#, options: .regularExpression),
              !text[..<separator.lowerBound].trimmingCharacters(in: .whitespaces).isEmpty else {
            name = text
            quantity = 0
            unit = ""
            comment = ""
            return
        }

        name = text[..<separator.lowerBound].trimmingCharacters(in: .whitespaces)
        let details = String(text[separator.upperBound...]).trimmingCharacters(in: .whitespaces)
        guard let match = amountExpression.firstMatch(
            in: details, range: NSRange(details.startIndex..., in: details)
        ), let amountRange = Range(match.range(at: 1), in: details),
           let amount = Double(details[amountRange].replacingOccurrences(of: ",", with: ".")),
           amount.isFinite, amount > 0 else {
            // Количество в модели не optional: 0 означает, что оно не распознано.
            // Сохраняем описание целиком, включая «по вкусу», дроби и диапазоны.
            quantity = 0
            unit = ""
            comment = details
            return
        }

        quantity = amount
        unit = Range(match.range(at: 2), in: details)
            .map { String(details[$0]).trimmingCharacters(in: .whitespaces) } ?? ""
        comment = Range(match.range(at: 3), in: details)
            .map { String(details[$0]).trimmingCharacters(in: .whitespaces) } ?? ""
    }
}
