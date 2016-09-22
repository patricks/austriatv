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
    func getMostViewed(_ completion: @escaping (_ successful: Bool, _ teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.mostViewed) { (successful, teaserItems) -> () in
            completion(successful: successful, teaserItems: teaserItems)
        }
    }
    
    /**
     Get newest episodes.
     */
    func getNewest(_ completion: @escaping (_ successful: Bool, _ teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.newest) { (successful, teaserItems) -> () in
            completion(successful: successful, teaserItems: teaserItems)
        }
    }
    
    /**
     Get recommended episodes.
     */
    func getRecommended(_ completion: @escaping (_ successful: Bool, _ teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.recommendations) { (successful, teaserItems) -> () in
            completion(successful: successful, teaserItems: teaserItems)
        }
    }
    
    /**
     Get recommended episodes.
     */
    func getHighlights(_ completion: @escaping (_ successful: Bool, _ teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.hightlights) { (successful, teaserItems) -> () in
            completion(successful: successful, teaserItems: teaserItems)
        }
    }
    
    /**
     Get the different teaser items.
     */
    fileprivate func getTeaserItemsForCategory(_ category: TeaserCategory, completion: @escaping (_ successful: Bool, _ teaserItems: [Teaser]?) -> ()) {
        var request: APIRequest
        
        switch category {
        case .mostViewed:
            request = APIRequest.mostViewed()
        case .newest:
            request = APIRequest.newest()
        case .recommendations:
            request = APIRequest.newest()
        case .hightlights:
            request = APIRequest.highlights()
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
                case .success(let value):
                    completion(successful: true, teaserItems: value.items)
                case .failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(successful: false, teaserItems: nil)
                }
        }
    }
    
    
    // MARK: Episode API Calls
    
    func getEpisode(_ episodeId: Int, completion: @escaping (_ successful: Bool, _ episode: Episode?) -> ()) {
        Alamofire.request(APIRequest.episode(episodeId: episodeId))
            
            .validate()
            
            .responseObject { (response: Response<EpisodeDetailResponse, NSError>) -> Void in
                
                switch response.result {
                case .success(let value):
                    completion(successful: true, episode: value.episode)
                case .failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(successful: false, episode: nil)
                }
        }
    }
    
    func getEpisodeByProgram(_ programId: Int, completion: @escaping (_ successful: Bool, _ episodes: [Episode]?) -> ()) {
        Alamofire.request(APIRequest.episodesByProgram(programId: programId))
            
            .validate()
            
            .responseObject { (response: Response<EpisodeShortsResponse, NSError>) -> Void in
                
                switch response.result {
                case .success(let value):
                    completion(successful: true, episodes: value.episodes)
                case .failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(successful: false, episodes: nil)
                }
        }
    }
    
    // MARK: Program API Calls
    
    func getPrograms(_ completion: @escaping (_ successful: Bool, _ programs: [Program]?) -> ()) {
        Alamofire.request(APIRequest.programs())
            
            .validate()
            
            .responseObject { (response: Response<ProgramShortsResponse, NSError>) -> Void in
                
                switch response.result {
                case .success(let value):
                    completion(successful: true, programs: value.programs)
                case .failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(successful: false, programs: nil)
                }
            }
    }
    
    // MARK: Livestream API Calls
    
    func getLivestreams(_ completion: @escaping (_ successful: Bool, _ episodes: [Episode]?) -> ()) {
        Alamofire.request(APIRequest.livestreams())
        
            .validate()
        
            .responseObject { (response: Response<EpisodeDetailsResponse, NSError>) -> Void in
                
                switch response.result {
                case .success(let value):
                    completion(successful: true, episodes: value.episodes)
                case .failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(successful: false,episodes: nil)
                }
            }
    }
}
