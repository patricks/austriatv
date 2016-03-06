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
    
    var URLRequest: NSMutableURLRequest {
        let result: (path: String, parameters: [String: AnyObject]?, httpMethod: String) = {
            
            switch self {
            case .MostViewed():
                return ("\(AppConstants.baseApiPath)/teaser_content/most_viewed", nil, "GET")
                
            case .Newest():
                return ("\(AppConstants.baseApiPath)/teaser_content/newest", nil, "GET")
                
            case .Recommendations():
                return ("\(AppConstants.baseApiPath)/teaser_content/recommendations", nil, "GET")
                
            case .Highlights():
                return ("\(AppConstants.baseApiPath)/teaser_content/highlights", nil, "GET")
                
            case .Episode(let episodeId):
                return ("\(AppConstants.baseApiPath)/episode/\(episodeId)/", nil, "GET")
                
            case .EpisodesByProgram(let programId):
                return ("\(AppConstants.baseApiPath)/episodes/by_program/\(programId)/", nil, "GET")
                
            case .Programs():
                let params = ["page": "\(0)", "entries_per_page": "\(1000)"]
                return ("\(AppConstants.baseApiPath)/programs", params, "GET")
            }
        }()
        
        let URL = NSURL(string: AppConstants.apiURL)
        let URLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(result.path))
        URLRequest.HTTPMethod = result.httpMethod
        
        let encoding = Alamofire.ParameterEncoding.URL
        
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
}
