//
//  LiveCollectionViewController.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.03.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import UIKit
import Kingfisher

class LiveCollectionViewController: UICollectionViewController {
    
    private let reuseCellIdentifier = "TeaserCell"
    
    private let apiManager = ApiManager()
    
    private var episodes = [Episode]()
    private var channels = [String: [Episode]]()
    private var sortedChannels = [(String, [Episode])]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Live", comment: "LiveTableViewController - Title")
        
        getDataFromServer()
    }
    
    // MARK: Data Source
    
    private func getDataFromServer() {
        
        apiManager.getLivestreams { (successful, episodes) in
            if successful {
                if let _ = episodes {
                    self.episodes = episodes!
                    
                    self.getChannels()
                    
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    private func getChannels() {
        
        for episode in episodes {
            if let channelName = episode.channel?.name {
                
                if channels[channelName] == nil {
                    channels[channelName] = [Episode]()
                }
                
                channels[channelName]?.append(episode)
            }
            
            // add episode to online channel if it is currently online
            
            if let publishState = episode.publishState {
                if publishState == Episode.PublishState.Online {
                    
                    let onlineChannelName = NSLocalizedString("Currently Available", comment: "Online Episodes Channel Name")
                    
                    if channels[onlineChannelName] == nil {
                        channels[onlineChannelName] = [Episode]()
                    }
                    
                    channels[onlineChannelName]?.append(episode)
                }
            }
        }
        
        sortChannels()
    }
    
    private func sortChannels() {
        sortedChannels = channels.sort { $0.0 < $1.0 }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension LiveCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 10
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCellIdentifier, forIndexPath: indexPath) as! TeaserCollectionViewCell
        
        return cell
    }
}
