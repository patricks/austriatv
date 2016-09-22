//
//  Video.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 01.04.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class Video: Mappable {
    
    var streamingURL: String?
    
    required init?(_ map: Map) { }
    
    func mapping(_ map: Map) {
        streamingURL <- map["streamingUrl"]
    }
}
