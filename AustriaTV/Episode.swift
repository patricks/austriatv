//
//  Episode.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import ObjectMapper

class Episode: Mappable {
    
    enum Type {
        case Short
        case Detail
    }
    
    var episodeId: Int?
    var title: String?
    var segments: [Segment]?
    var date: NSDate?
    var images: [Image]?
    var descriptions: [Description]?
    
    var episodeType: Type {
        get {
            // if segments property is set, details already loaded
            if let _ = self.segments {
                return .Detail
            }
            
            return .Short
        }
    }
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        
        let dateTransform = TransformOf<NSDate, String>(fromJSON: { (value: String?) -> NSDate? in
            // transform value from String? to NSDate?
            if let value = value {
                // TODO: fix the timezone problem
                let date = NSDate(fromString: value, format: .Custom("dd.MM.yyyy HH:mm:ss"))
                // Add the 1 hour form the timezone
                return date.dateByAddingHours(1)
            }
            
            return NSDate()
            }, toJSON: { (value: NSDate?) -> String? in
                // transform value from NSDate? to String?
                if let value = value {
                    return String(value)
                }
                return nil
        })
        
        episodeId <- map["episodeId"]
        title <- map["title"]
        segments <- map["segments"]
        date <- (map["date"], dateTransform)
        images <- map["images"]
        descriptions <- map["descriptions"]
    }
    
    // MARK: format output
    
    func getFormatedTitle() -> String {
        var outputTitle = ""
        
        if let _ = title {
            outputTitle += title!
        }
        
        if let _ = date {
            let dateString = date!.toString(dateStyle: .ShortStyle, timeStyle: .ShortStyle, doesRelativeDateFormatting: true)
            outputTitle += " \(dateString)"
        }
        
        return outputTitle
    }
    
    // MARK: images
    
    func getFullImageURL() -> NSURL? {
        return getImageURL("image_full")
    }
    
    private func getImageURL(name: String) -> NSURL? {
        if let images = images {
            for image in images {
                if image.name == name {
                    if let url = image.url {
                        return NSURL(string: url)
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: descriptions
    
    func getFullDescription() -> String? {
        return getDescription("description")
    }
    
    func getTeaserDescription() -> String? {
        return getDescription("teaser_text")
    }
    
    func getSmallTeaserDescription() -> String? {
        return getDescription("small_teaser_text")
    }
    
    func getTopicsTeaserDescription() -> String? {
        return getDescription("topics_teaser_text")
    }
    
    private func getDescription(fieldName: String) -> String? {
        if let descriptions = descriptions {
            for description in descriptions {
                if description.fieldName == fieldName {
                    return description.text
                }
            }
        }
        
        return nil
    }
}

class Segment: Mappable {
    
    var videos: [Video]?
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        videos <- map["videos"]
    }
}

class Video: Mappable {
    
    var streamingURL: String?
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        streamingURL <- map["streamingUrl"]
    }
}

class Description: Mappable {
    
    var fieldName: String?
    var text: String?
    var maxLength: Int?
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        fieldName <- map["fieldName"]
        text <- map["text"]
        maxLength <- map["maxLength"]
    }
}
