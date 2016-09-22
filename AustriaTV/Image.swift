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
    fileprivate let urlKey = "url"
    fileprivate let nameKey = "name"
    fileprivate let widthKey = "width"
    fileprivate let heightKey = "height"
    
    required init?(coder aDecoder: NSCoder) {
        if let url = aDecoder.decodeObject(forKey: urlKey) as? String {
            self.url = url
        }
        
        if let name = aDecoder.decodeObject(forKey: nameKey) as? String {
            self.name = name
        }
        
        self.width = aDecoder.decodeInteger(forKey: widthKey)
        
        self.height = aDecoder.decodeInteger(forKey: heightKey)
    }
    
    func encode(with aCoder: NSCoder) {
        if let url = self.url {
            aCoder.encode(url, forKey: urlKey)
        }
        
        if let name = self.name {
            aCoder.encode(name, forKey: nameKey)
        }
        
        if let width = self.width {
            aCoder.encode(width, forKey: widthKey)
        }
        
        if let height = self.height {
            aCoder.encode(height, forKey: heightKey)
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
