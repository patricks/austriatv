//
//  Segment.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 01.04.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class Segment: Mappable {
    
    var videos: [Video]?
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        videos <- map["videos"]
    }
}