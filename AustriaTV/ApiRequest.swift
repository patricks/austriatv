//
//  ApiRequest.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import Alamofire

enum APIRequest: URLRequestConvertible {

    // API Calls
    // General
    case MostViewed()
    case Newest()
    case Recommendations()
    case Highlights()
    
    // Episode
    case Episode(episodeId: Int)
    case EpisodesByProgram(programId: Int)
    
    // Programs
    case Programs()
    
    // Livestreams
    case Livestreams()
    
    var URLRequest: NSMutableURLRequest {
        let result: (path: String, parameters: [String: AnyObject]?, httpMethod: String) = {
            
            switch self {
            case .MostViewed():
                return ("\(AppConstants.BaseApiPath)/teaser_content/most_viewed", nil, "GET")
                
            case .Newest():
                return ("\(AppConstants.BaseApiPath)/teaser_content/newest", nil, "GET")
                
            case .Recommendations():
                return ("\(AppConstants.BaseApiPath)/teaser_content/recommendations", nil, "GET")
                
            case .Highlights():
                return ("\(AppConstants.BaseApiPath)/teaser_content/highlights", nil, "GET")
                
            case .Episode(let episodeId):
                return ("\(AppConstants.BaseApiPath)/episode/\(episodeId)/", nil, "GET")
                
            case .EpisodesByProgram(let programId):
                return ("\(AppConstants.BaseApiPath)/episodes/by_program/\(programId)/", nil, "GET")
                
            case .Programs():
                let params = ["page": "\(0)", "entries_per_page": "\(1000)"]
                return ("\(AppConstants.BaseApiPath)/programs", params, "GET")
                
            case .Livestreams():
                let now = NSDate()
                
                let startTime = now.toString(format: .Custom("yyyyMMddHHmm"))
                let endTime = now.dateByAddingDays(1).toString(format: .Custom("yyyyMMddHHmm"))
                
                return ("\(AppConstants.BaseApiPath)/livestreams/from/\(startTime)/till/\(endTime)/detail", nil, "GET")
            }
        }()
        
        let URL = NSURL(string: AppConstants.ApiURL)
        let URLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(result.path))
        URLRequest.HTTPMethod = result.httpMethod
        
        let encoding = Alamofire.ParameterEncoding.URL
        
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
}
