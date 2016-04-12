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
    
    // NSCoding and JSON keys
    private let programIdKey = "programId"
    private let nameKey = "name"
    private let imagesKey = "images"
    private let programDescriptionKey = "programDescription"
    
    required init?(_ map: Map) { }
    
    required init?(coder aDecoder: NSCoder) {
        self.programId = aDecoder.decodeIntegerForKey(programIdKey)
        
        if let name = aDecoder.decodeObjectForKey(nameKey) as? String {
            self.name = name
        }
        
        if let programDescription = aDecoder.decodeObjectForKey(programDescriptionKey) as? String {
            self.programDescription = programDescription
        }
        
        if let images = aDecoder.decodeObjectForKey(imagesKey) as? [Image] {
            self.images = images
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let programId = self.programId {
            aCoder.encodeInteger(programId, forKey: programIdKey)
        }
        
        if let name = self.name {
            aCoder.encodeObject(name, forKey: nameKey)
        }
        
        if let programDescription = self.programDescription {
            aCoder.encodeObject(programDescription, forKey: programDescriptionKey)
        }
        
        if let images = self.images {
            aCoder.encodeObject(images, forKey: imagesKey)
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
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? Program {
            return self.programId! == other.programId
        } else {
            return false
        }
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