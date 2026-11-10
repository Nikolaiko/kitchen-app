//
//  TagView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 04.11.2026.
//


//
//  TagView.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 02.11.2026.
//

import SwiftUI
import UIKit

struct TagView: View {

    var name: String
    var color: UIColor?

    var body: some View {
        Text(name)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Color(uiColor: color ?? .systemBlue),
                in: Capsule()
            )
    }
}

#Preview {
    TagView(name: "Суп")
}