//
//  EpisodeDetailResponse.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class EpisodeDetailResponse: Mappable {
    var episode: Episode?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        episode <- map["episodeDetail"]
    }
}
