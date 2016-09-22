//
//  Channel.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 01.04.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class Channel: Mappable {
    
    var channelId: Int?
    var name: String?
    var reel: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        channelId <- map["channelId"]
        name <- map["name"]
        reel <- map["reel"]
    }
}
