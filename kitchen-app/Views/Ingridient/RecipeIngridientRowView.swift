//
//  RecipeIngridientRowView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 13.11.2026.
//

import SwiftUI

struct RecipeIngridientRowView: View {
    let name: String
    let quantity: Double
    let unit: String
    let comment: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(name)
                Spacer()
                Text("\(quantity.formatted()) \(unit)")
                    .foregroundStyle(.secondary)
            }
            if !comment.isEmpty {
                Text(comment)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

