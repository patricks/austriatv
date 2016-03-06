//
//  TeaserCategory.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 05.03.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation

enum TeaserCategory: Int {
    case Hightlights
    case Newest
    case MostViewed
    case Recommendations
    
    static let allCategories: [TeaserCategory] = [.Hightlights, .Newest, .MostViewed, .Recommendations]
}

extension TeaserCategory: CustomStringConvertible {
    var description: String {
        switch self {
        case .Hightlights:
            return NSLocalizedString("Highlights", comment: "Category: Highlights")
        case .Newest:
            return NSLocalizedString("Newest", comment: "Category: Newest")
        case .MostViewed:
            return NSLocalizedString("Most Viewed", comment: "Category: Most Viewed")
        case .Recommendations:
            return NSLocalizedString("Recommentations", comment: "Category: Recommentations")
        }
    }
}