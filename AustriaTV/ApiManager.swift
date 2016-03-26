//
//  ApiManager.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class ApiManager {
    
    // MARK: General API Calls
    
    /**
    Get mosted viewed episodes.
    */
    func getMostViewed(completion: (successful: Bool, teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.MostViewed) { (successful, teaserItems) -> () in
            completion(successful: successful, teaserItems: teaserItems)
        }
    }
    
    /**
     Get newest episodes.
     */
    func getNewest(completion: (successful: Bool, teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.Newest) { (successful, teaserItems) -> () in
            completion(successful: successful, teaserItems: teaserItems)
        }
    }
    
    /**
     Get recommended episodes.
     */
    func getRecommended(completion: (successful: Bool, teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.Recommendations) { (successful, teaserItems) -> () in
            completion(successful: successful, teaserItems: teaserItems)
        }
    }
    
    /**
     Get recommended episodes.
     */
    func getHighlights(completion: (successful: Bool, teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.Hightlights) { (successful, teaserItems) -> () in
            completion(successful: successful, teaserItems: teaserItems)
        }
    }
    
    /**
     Get the different teaser items.
     */
    private func getTeaserItemsForCategory(category: TeaserCategory, completion: (successful: Bool, teaserItems: [Teaser]?) -> ()) {
        var request: APIRequest
        
        switch category {
        case .MostViewed:
            request = APIRequest.MostViewed()
        case .Newest:
            request = APIRequest.Newest()
        case .Recommendations:
            request = APIRequest.Newest()
        case .Hightlights:
            request = APIRequest.Highlights()
        }
        
        Alamofire.request(request)
            /*
            .responseString { response in
            Log.debug("Success: \(response.result.isSuccess)")
            Log.debug("Response String: \(response.result.value)")
            */
            
            .validate()
            
            .responseObject { (response: Response<TeaserItemsResponse, NSError>) -> Void in
                
                switch response.result {
                case .Success(let value):
                    completion(successful: true, teaserItems: value.items)
                case .Failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(successful: false, teaserItems: nil)
                }
        }
    }
    
    
    // MARK: Episode API Calls
    
    func getEpisode(episodeId: Int, completion: (successful: Bool, episode: Episode?) -> ()) {
        Alamofire.request(APIRequest.Episode(episodeId: episodeId))
            
            .validate()
            
            .responseObject { (response: Response<EpisodeDetailResponse, NSError>) -> Void in
                
                switch response.result {
                case .Success(let value):
                    completion(successful: true, episode: value.episode)
                case .Failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(successful: false, episode: nil)
                }
        }
    }
    
    func getEpisodeByProgram(programId: Int, completion: (successful: Bool, episodes: [Episode]?) -> ()) {
        Alamofire.request(APIRequest.EpisodesByProgram(programId: programId))
            
            .validate()
            
            .responseObject { (response: Response<EpisodeShortsResponse, NSError>) -> Void in
                
                switch response.result {
                case .Success(let value):
                    completion(successful: true, episodes: value.episodes)
                case .Failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(successful: false, episodes: nil)
                }
        }
    }
    
    // MARK: Program API Calls
    
    func getPrograms(completion: (successful: Bool, programs: [Program]?) -> ()) {
        Alamofire.request(APIRequest.Programs())
            
            .validate()
            
            .responseObject { (response: Response<ProgramShortsResponse, NSError>) -> Void in
                
                switch response.result {
                case .Success(let value):
                    completion(successful: true, programs: value.programs)
                case .Failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(successful: false, programs: nil)
                }
            }
    }
    
    // MARK: Livestream API Calls
    
    func getLivestreams(completion: (successful: Bool, episodes: [Episode]?) -> ()) {
        Alamofire.request(APIRequest.Livestreams())
        
            .validate()
        
            .responseObject { (response: Response<EpisodeDetailsResponse, NSError>) -> Void in
                
                switch response.result {
                case .Success(let value):
                    completion(successful: true, episodes: value.episodes)
                case .Failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(successful: false,episodes: nil)
                }
            }
    }
}
