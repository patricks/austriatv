//
//  ProgramShortsResponse.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 27.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class ProgramShortsResponse: Mappable {
    var programs: [Program]?
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        programs <- map["programShorts"]
    }
}