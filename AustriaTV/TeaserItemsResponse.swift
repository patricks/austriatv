//
//  TeaserItemsResponse.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class TeaserItemsResponse: Mappable {
    var items: [Teaser]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        items <- map["teaserItems"]
    }
}
