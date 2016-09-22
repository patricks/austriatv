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
    case mostViewed()
    case newest()
    case recommendations()
    case highlights()
    
    // Episode
    case episode(episodeId: Int)
    case episodesByProgram(programId: Int)
    
    // Programs
    case programs()
    
    // Livestreams
    case livestreams()
    
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: [String: AnyObject]?, httpMethod: String) = {
            
            switch self {
            case .mostViewed():
                return ("\(AppConstants.BaseApiPath)/teaser_content/most_viewed", nil, "GET")
                
            case .newest():
                return ("\(AppConstants.BaseApiPath)/teaser_content/newest", nil, "GET")
                
            case .recommendations():
                return ("\(AppConstants.BaseApiPath)/teaser_content/recommendations", nil, "GET")
                
            case .highlights():
                return ("\(AppConstants.BaseApiPath)/teaser_content/highlights", nil, "GET")
                
            case .episode(let episodeId):
                return ("\(AppConstants.BaseApiPath)/episode/\(episodeId)/", nil, "GET")
                
            case .episodesByProgram(let programId):
                return ("\(AppConstants.BaseApiPath)/episodes/by_program/\(programId)/", nil, "GET")
                
            case .programs():
                let params = ["page": "\(0)", "entries_per_page": "\(1000)"]
                return ("\(AppConstants.BaseApiPath)/programs", params as [String : AnyObject]?, "GET")
                
            case .livestreams():
                let now = Date()
                
                let startTime = now.toString(.custom("yyyyMMddHHmm"))
                let endTime = now.dateByAddingDays(1).toString(.custom("yyyyMMddHHmm"))
                
                return ("\(AppConstants.BaseApiPath)/livestreams/from/\(startTime)/till/\(endTime)/detail", nil, "GET")
            }
        }()
        
        let url = Foundation.URL(string: AppConstants.ApiURL)
        var urlRequest = URLRequest(url: (url?.appendingPathComponent(result.path))!)
        urlRequest.httpMethod = result.httpMethod
        
        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }
}
