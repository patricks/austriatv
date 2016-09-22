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
    
    internal enum `Type` {
        case short
        case detail
    }
    
    enum PublishState: String {
        case Online = "online"
        case Offline = "offline"
    }
    
    enum EpisodeType: String {
        case videoOnDemand = "vod"
        case livestream = "livestream"
    }
    
    var episodeId: Int?
    var title: String?
    var segments: [Segment]?
    var date: Date?
    var images: [Image]?
    var descriptions: [Description]?
    var duration: Int?
    var channel: Channel?
    var publishState: PublishState?
    var episodeType: EpisodeType?
    var liveStreamStart: Date?
    var liveStreamEnd: Date?
    var livestreamingVideos: [Video]?
    
    var type: Type {
        get {
            // if segments property is set, details already loaded
            if let _ = self.segments {
                return .detail
            }
            
            return .short
        }
    }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        let dateTransform = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
            // transform value from String? to NSDate?
            if let value = value {
                return Date(fromString: value, format: .custom("dd.MM.yyyy HH:mm:ss"), timeZone: .local)
            }
            
            return Date()
            }, toJSON: { (value: Date?) -> String? in
                // transform value from NSDate? to String?
                if let value = value {
                    return String(describing: value)
                }
                return nil
        })
        
        episodeId <- map["episodeId"]
        title <- map["title"]
        segments <- map["segments"]
        date <- (map["date"], dateTransform)
        images <- map["images"]
        descriptions <- map["descriptions"]
        duration <- map["duration"]
        channel <- map["channel"]
        publishState <- (map["publishState"], EnumTransform<PublishState>())
        episodeType <- (map["episodeType"], EnumTransform<EpisodeType>())
        liveStreamStart <- (map["livestreamStart"], dateTransform)
        liveStreamEnd <- (map["livestreamEnd"], dateTransform)
        livestreamingVideos <- map["livestreamStreamingUrls"]
    }
    
    // MARK: format output
    
    func getFormatedTitle() -> String {
        var outputTitle = ""
        
        if let _ = title {
            outputTitle += title!
        }
        
        if let _ = date {
            let dateString = date!.toString(dateStyle: .short, timeStyle: .short, doesRelativeDateFormatting: true)
            outputTitle += " \(dateString)"
        }
        
        return outputTitle
    }
    
    // MARK: images
    
    func getFullImageURL() -> URL? {
        
        if let episodeType = self.episodeType {
            switch episodeType {
            case .videoOnDemand:
                return getImageURL("image_full")
            case .livestream:
                return getImageURL("logo")
            }
        }
        
        return nil
    }
    
    func getPreviewImageURL() -> URL? {
        return getImageURL("logo4_mobile")
    }
    
    fileprivate func getImageURL(_ name: String) -> URL? {
        if let images = images {
            for image in images {
                if let imageName = image.name {
                    if imageName == name {
                        if let url = image.url {
                            return URL(string: url)
                        }
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
    
    fileprivate func getDescription(_ fieldName: String) -> String? {
        if let descriptions = descriptions {
            for description in descriptions {
                if description.fieldName == fieldName {
                    return description.text
                }
            }
        }
        
        return nil
    }
    
    // MARK: duration
    
    fileprivate func formatDuration(durationInSeconds duration: Int) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        
        var components = DateComponents()
        
        // set hours, minutes or second
        components.hour = Int(duration / 3600)
        components.minute = Int((duration / 60) % 60)
        components.second = Int(duration % 60)
        
        return formatter.string(from: components)
    }
    
    func getFormatedDuration() -> String? {
        if let duration = duration {
            return formatDuration(durationInSeconds: duration)
        }
        
        return nil
    }
    
    func getDurationToLiveStreamStart() -> Int? {
        if let liveStreamStart = liveStreamStart {
            let now = Date()
            
            if now.isLessThanDate(liveStreamStart) {
                return now.secondsBeforeDate(liveStreamStart)
            }
        }
        
        return nil
    }
    
    func getFormatedDurationToLiveStreamStart() -> String? {
        if let seconds = getDurationToLiveStreamStart() {
            return formatDuration(durationInSeconds: seconds)
        }
        
        return nil
    }
    
    // MARK: video stream
    
    func getVideoStreamURL() -> URL? {
        return nil
    }
    
    func isLiveStreamOnline() -> Bool {
        if let liveStreamStart = liveStreamStart, let liveStreamEnd = liveStreamEnd {
            let now = Date()
            
            if now.isGreaterThanDate(liveStreamStart) && now.isLessThanDate(liveStreamEnd) {
                return true
            }
        }
        
        return false
    }
}
