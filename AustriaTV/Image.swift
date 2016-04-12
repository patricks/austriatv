//
//  Image.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 05.03.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class Image: NSObject, Mappable, NSCoding {
    
    var url: String?
    var name: String?
    var width: Int?
    var height: Int?
    
    // NSCoding and JSON keys
    private let urlKey = "url"
    private let nameKey = "name"
    private let widthKey = "width"
    private let heightKey = "height"
    
    required init?(coder aDecoder: NSCoder) {
        if let url = aDecoder.decodeObjectForKey(urlKey) as? String {
            self.url = url
        }
        
        if let name = aDecoder.decodeObjectForKey(nameKey) as? String {
            self.name = name
        }
        
        self.width = aDecoder.decodeIntegerForKey(widthKey)
        
        self.height = aDecoder.decodeIntegerForKey(heightKey)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let url = self.url {
            aCoder.encodeObject(url, forKey: urlKey)
        }
        
        if let name = self.name {
            aCoder.encodeObject(name, forKey: nameKey)
        }
        
        if let width = self.width {
            aCoder.encodeInteger(width, forKey: widthKey)
        }
        
        if let height = self.height {
            aCoder.encodeInteger(height, forKey: heightKey)
        }
    }
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        url <- map[urlKey]
        name <- map[nameKey] // TODO: set a enum type for the different image types
        width <- map[widthKey]
        height <- map[heightKey]
    }
}
