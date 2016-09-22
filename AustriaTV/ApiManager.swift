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
            completion(successful, teaserItems)
        }
    }
    
    /**
     Get newest episodes.
     */
    func getNewest(_ completion: @escaping (_ successful: Bool, _ teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.newest) { (successful, teaserItems) -> () in
            completion(successful, teaserItems)
        }
    }
    
    /**
     Get recommended episodes.
     */
    func getRecommended(_ completion: @escaping (_ successful: Bool, _ teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.recommendations) { (successful, teaserItems) -> () in
            completion(successful, teaserItems)
        }
    }
    
    /**
     Get recommended episodes.
     */
    func getHighlights(_ completion: @escaping (_ successful: Bool, _ teaserItems: [Teaser]?) -> ()) {
        
        getTeaserItemsForCategory(.hightlights) { (successful, teaserItems) -> () in
            completion(successful, teaserItems)
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
            
            .responseObject { (response: DataResponse<TeaserItemsResponse>) -> Void in
                
                switch response.result {
                case .success(let value):
                    completion(true, value.items)
                case .failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(false, nil)
                }
        }
    }
    
    
    // MARK: Episode API Calls
    
    func getEpisode(_ episodeId: Int, completion: @escaping (_ successful: Bool, _ episode: Episode?) -> ()) {
        Alamofire.request(APIRequest.episode(episodeId: episodeId))
            
            .validate()
            
            .responseObject { (response: DataResponse<EpisodeDetailResponse>) -> Void in
                
                switch response.result {
                case .success(let value):
                    completion(true, value.episode)
                case .failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(false, nil)
                }
        }
    }
    
    func getEpisodeByProgram(_ programId: Int, completion: @escaping (_ successful: Bool, _ episodes: [Episode]?) -> ()) {
        Alamofire.request(APIRequest.episodesByProgram(programId: programId))
            
            .validate()
            
            .responseObject { (response: DataResponse<EpisodeShortsResponse>) -> Void in
                
                switch response.result {
                case .success(let value):
                    completion(true, value.episodes)
                case .failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(false, nil)
                }
        }
    }
    
    // MARK: Program API Calls
    
    func getPrograms(_ completion: @escaping (_ successful: Bool, _ programs: [Program]?) -> ()) {
        Alamofire.request(APIRequest.programs())
            
            .validate()
            
            .responseObject { (response: DataResponse<ProgramShortsResponse>) -> Void in
                
                switch response.result {
                case .success(let value):
                    completion(true, value.programs)
                case .failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(false, nil)
                }
            }
    }
    
    // MARK: Livestream API Calls
    
    func getLivestreams(_ completion: @escaping (_ successful: Bool, _ episodes: [Episode]?) -> ()) {
        Alamofire.request(APIRequest.livestreams())
        
            .validate()
        
            .responseObject { (response: DataResponse<EpisodeDetailsResponse>) -> Void in
                
                switch response.result {
                case .success(let value):
                    completion(true, value.episodes)
                case .failure(let error):
                    Log.debug(error.localizedDescription)
                    completion(false,nil)
                }
            }
    }
}
