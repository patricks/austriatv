//
//  Description.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 01.04.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class Description: Mappable {
    
    var fieldName: String?
    var text: String?
    var maxLength: Int?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        fieldName <- map["fieldName"]
        text <- map["text"]
        maxLength <- map["maxLength"]
    }
}
