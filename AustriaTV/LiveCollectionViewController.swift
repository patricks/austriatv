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
    private let reuseHeaderIdentifier = "TeaserHeader"
    
    private let apiManager = ApiManager()
    
    private var sortedChannels = [(String, [Episode])]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        getDataFromServer()
    }
    
    // MARK: Data Source
    
    private func getDataFromServer() {
        
        apiManager.getLivestreams { (successful, episodes) in
            if successful {
                if let _ = episodes {
                    self.sortedChannels = self.parseChannels(episodes!)
                    
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    private func parseChannels(episodes: [Episode]) -> [(String, [Episode])] {
        var channels = [String: [Episode]]()
        
        for episode in episodes {
            if let channelName = episode.channel?.name {
                
                if channels[channelName] == nil {
                    channels[channelName] = [Episode]()
                }
                
                channels[channelName]?.append(episode)
            }
            
            // add episode to online channel if it is currently online
            if episode.isLiveStreamOnline() {
                let onlineChannelName = NSLocalizedString("Currently Available", comment: "Online Episodes Channel Name")
                
                if channels[onlineChannelName] == nil {
                    channels[onlineChannelName] = [Episode]()
                }
                
                channels[onlineChannelName]?.append(episode)
            }
        }
        
        // sort the channels
        return channels.sort { $0.0 < $1.0 }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEpisode" {
            if let indexPaths = collectionView!.indexPathsForSelectedItems() {
                if let indexPath = indexPaths.first {
                    let episodes = sortedChannels[indexPath.section].1
                    let episode = episodes[indexPath.row]
                    
                    if let episodeId = episode.episodeId {
                        apiManager.getEpisode(episodeId, completion: { (successful, episode) -> () in
                            if successful {
                                if let episode = episode {
                                    if let viewController = segue.destinationViewController as? EpisodeDetailsViewController {
                                        viewController.episode = episode
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension LiveCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sortedChannels.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let channel = sortedChannels[section]
        
        return channel.1.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCellIdentifier, forIndexPath: indexPath) as! TeaserCollectionViewCell
        
        let episodes = sortedChannels[indexPath.section].1
        
        let episode = episodes[indexPath.row]
        
        let placeholderImage = UIImage(named: "Overview_Placeholder")
        
        // Configure the cell
        if let imageURL = episode.getPreviewImageURL() {
            cell.teaserImageView.kf_setImageWithURL(imageURL, placeholderImage: placeholderImage)
        } else {
            cell.teaserImageView.image = placeholderImage
        }
        
        if let title = episode.title {
            cell.teaserTitle.text = title
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, forIndexPath: indexPath) as! OverviewCollectionHeaderView
            
            let channel = sortedChannels[indexPath.section]
            
            headerView.titleLabel.text = channel.0
            
            reusableView = headerView
        } else {
            reusableView = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        }
        
        return reusableView
    }
}
