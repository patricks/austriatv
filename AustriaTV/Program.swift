//
//  Program.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 27.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class Program: NSObject, Mappable, NSCoding {
    
    enum `Type` {
        case short
        case detail
    }
    
    var programId: Int?
    var name: String?
    var images: [Image]?
    var programDescription: String?

    var programType: Type {
        get {
            // if programDescription property is set, details already loaded
            if let _ = self.programDescription {
                return .detail
            }
            
            return .short
        }
    }
    
    // NSCoding and JSON keys
    fileprivate let programIdKey = "programId"
    fileprivate let nameKey = "name"
    fileprivate let imagesKey = "images"
    fileprivate let programDescriptionKey = "programDescription"
    
    required init?(map: Map) { }
    
    required init?(coder aDecoder: NSCoder) {
        self.programId = aDecoder.decodeInteger(forKey: programIdKey)
        
        if let name = aDecoder.decodeObject(forKey: nameKey) as? String {
            self.name = name
        }
        
        if let programDescription = aDecoder.decodeObject(forKey: programDescriptionKey) as? String {
            self.programDescription = programDescription
        }
        
        if let images = aDecoder.decodeObject(forKey: imagesKey) as? [Image] {
            self.images = images
        }
    }
    
    func encode(with aCoder: NSCoder) {
        if let programId = self.programId {
            aCoder.encode(programId, forKey: programIdKey)
        }
        
        if let name = self.name {
            aCoder.encode(name, forKey: nameKey)
        }
        
        if let programDescription = self.programDescription {
            aCoder.encode(programDescription, forKey: programDescriptionKey)
        }
        
        if let images = self.images {
            aCoder.encode(images, forKey: imagesKey)
        }
    }
    
    func mapping(map: Map) {
        programId <- map[programIdKey]
        name <- map[nameKey]
        images <- map[imagesKey]
        programDescription <- map[programDescriptionKey]
    }
    
    override var hashValue: Int {
        return programId!.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Program {
            return self.programId! == other.programId
        } else {
            return false
        }
    }
    
    func getImageURL() -> URL? {
        if let images = images {
            for image in images {
                if image.name == "logo" {
                    if let url = image.url {
                        return URL(string: url)
                    }
                }
            }
        }
        
        return nil
    }
}
