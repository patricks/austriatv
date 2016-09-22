//
//  TeaserItem.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class Teaser: Mappable {
    
    var episodeId: Int?
    var title: String?
    var images: [Image]?
    
    required init?(_ map: Map) { }
    
    func mapping(_ map: Map) {
        episodeId <- map["episodeId"]
        title <- map["title"]
        images <- map["images"]
    }
    
    func getImageURL() -> URL? {
        if let images = images {
            for image in images {
                if let imageName = image.name {
                    if imageName == "image2_mobile" {
                        if let url = image.url {
                            return URL(string: url)
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
