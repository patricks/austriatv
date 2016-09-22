//
//  TeaserCategory.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 05.03.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation

enum TeaserCategory: Int {
    case hightlights
    case newest
    case mostViewed
    case recommendations
    
    static let allCategories: [TeaserCategory] = [.hightlights, .newest, .mostViewed, .recommendations]
}

extension TeaserCategory: CustomStringConvertible {
    var description: String {
        switch self {
        case .hightlights:
            return NSLocalizedString("Highlights", comment: "Category: Highlights")
        case .newest:
            return NSLocalizedString("Newest", comment: "Category: Newest")
        case .mostViewed:
            return NSLocalizedString("Most Viewed", comment: "Category: Most Viewed")
        case .recommendations:
            return NSLocalizedString("Recommentations", comment: "Category: Recommentations")
        }
    }
}
