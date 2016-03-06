//
//  Program.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 27.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class Program: Mappable {
    
    enum Type {
        case Short
        case Detail
    }
    
    var programId: Int?
    var name: String?
    var images: [Image]?
    var programDescription: String?

    var programType: Type {
        get {
            // if programDescription property is set, details already loaded
            if let _ = self.programDescription {
                return .Detail
            }
            
            return .Short
        }
    }
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        programId <- map["programId"]
        name <- map["name"]
        images <- map["images"]
        programDescription <- map["programDescription"]
    }
    
    func getImageURL() -> NSURL? {
        if let images = images {
            for image in images {
                if image.name == "logo" {
                    if let url = image.url {
                        return NSURL(string: url)
                    }
                }
            }
        }
        
        return nil
    }
}