//
//  TagColorTransform.swift
//  kitchen-app
//
//  Created by Nikolai Baklanov on 04.11.2026.
//

import UIKit

class TagColorTransform: NSSecureUnarchiveFromDataTransformer {
    override class func transformedValueClass() -> AnyClass {
        UIColor.self
    }

    override class var allowedTopLevelClasses: [AnyClass] {
        [UIColor.self]
    }

    static func register() {
        ValueTransformer.setValueTransformer(TagColorTransform(), forName: NSValueTransformerName("TagColorTransform"))
    }
}

