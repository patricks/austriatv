//
//  EpisodeDetailsResponse.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.03.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class EpisodeDetailsResponse: Mappable {
    var episodes: [Episode]?
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        episodes <- map["episodeDetails"]
    }
}