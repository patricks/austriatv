//
//  Image.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 05.03.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class Image: Mappable {
    
    var url: String?
    var name: String?
    var width: Int?
    var height: Int?
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        url <- map["url"]
        name <- map["name"] // TODO: set a enum type for the different image types
        width <- map["width"]
        height <- map["height"]
    }
}
