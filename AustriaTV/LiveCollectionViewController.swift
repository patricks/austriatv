//
//  LiveCollectionViewController.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.03.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import UIKit
import Kingfisher
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class LiveCollectionViewController: UICollectionViewController {
    
    fileprivate var activityIndicatorView: UIActivityIndicatorView!
    
    fileprivate let reuseCellIdentifier = "TeaserCell"
    fileprivate let reuseHeaderIdentifier = "TeaserHeader"
    
    fileprivate let apiManager = ApiManager()
    
    fileprivate var sortedChannels = [(String, [Episode])]()
    
    fileprivate var reloadTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getDataFromServer()
    }
    
    fileprivate func setupLoadingIndicator() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = AppConstants.ActivityIndicatorColor
        
        activityIndicatorView.startAnimating()
        
        self.view.addSubview(activityIndicatorView)
    }
    
    // MARK: Data Source
    
    fileprivate func getDataFromServer() {
        
        apiManager.getLivestreams { (successful, episodes) in
            if successful {
                if let _ = episodes {
                    self.sortedChannels = self.parseChannels(episodes!)
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    fileprivate func parseChannels(_ episodes: [Episode]) -> [(String, [Episode])] {
        var channels = [String: [Episode]]()
        
        var durationToLiveStream: Int?
        
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
            } else { // get duration until live stream is online, and refresh the view.
                
                if let seconds = episode.getDurationToLiveStreamStart() {
                    
                    if durationToLiveStream == nil {
                        durationToLiveStream = seconds
                        Log.debug("next reload for episode: \(episode.title)")
                    } else if durationToLiveStream > seconds {
                        durationToLiveStream = seconds
                        Log.debug("next reload for episode: \(episode.title)")
                    }
                }
            }
        }
        
        // set the data reloading timer
        if let durationInSeconds = durationToLiveStream {
            // add additional seconds
            Log.debug("Next reload is in: \(durationInSeconds + 5) seconds")
            setDurationForServerReload(Double(durationInSeconds + 5))
        } else {
            // default reload after 5 minutes
            Log.debug("No Next reload so reload in: \(18000) seconds")
            setDurationForServerReload(Double(18000))
        }
        
        // sort the channels
        return channels.sorted { $0.0 < $1.0 }
    }
    
    fileprivate func setDurationForServerReload(_ seconds: Double) {
        reloadTimer.invalidate()
        reloadTimer = Timer.scheduledTimer(
            timeInterval: seconds,
            target: self,
            selector: #selector(LiveCollectionViewController.reloadServerData),
            userInfo: nil,
            repeats: false
        )
    }
    
    func reloadServerData() {
        Log.debug("reloading server data")
        getDataFromServer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEpisode" {
            if let indexPaths = collectionView!.indexPathsForSelectedItems {
                if let indexPath = indexPaths.first {
                    let episodes = sortedChannels[(indexPath as NSIndexPath).section].1
                    let episode = episodes[(indexPath as NSIndexPath).row]
                    
                    if let episodeId = episode.episodeId {
                        apiManager.getEpisode(episodeId, completion: { (successful, episode) -> () in
                            if successful {
                                if let episode = episode {
                                    if let viewController = segue.destination as? EpisodeDetailsViewController {
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sortedChannels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let channel = sortedChannels[section]
        
        return channel.1.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellIdentifier, for: indexPath) as! TeaserCollectionViewCell
        
        let episodes = sortedChannels[(indexPath as NSIndexPath).section].1
        
        let episode = episodes[(indexPath as NSIndexPath).row]
        
        let placeholderImage = UIImage(named: "Overview_Placeholder")
        
        // Configure the cell
        if let imageURL = episode.getPreviewImageURL() {
            cell.teaserImageView.kf.setImage(with: imageURL, placeholder: placeholderImage)
        } else {
            cell.teaserImageView.image = placeholderImage
        }
        
        if let title = episode.title {
            cell.teaserTitle.text = title
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath) as! OverviewCollectionHeaderView
            
            let channel = sortedChannels[(indexPath as NSIndexPath).section]
            
            headerView.titleLabel.text = channel.0
            
            reusableView = headerView
        } else {
            reusableView = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        
        return reusableView
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodes = sortedChannels[(indexPath as NSIndexPath).section].1
        let episode = episodes[(indexPath as NSIndexPath).row]
        
        if episode.isLiveStreamOnline() {
            performSegue(withIdentifier: "ShowEpisode", sender: self)
        } else {
            var message = NSLocalizedString("Livestream is currently not available", comment: "Livestream Not Available Dialog Unknown Time")
            
            if let duration = episode.getFormatedDurationToLiveStreamStart() {
                message = String.localizedStringWithFormat(NSLocalizedString("Livestream is available in %@", comment: "Livestream Not Available Dialog Message"), duration)
            }
            
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            let okTitle = NSLocalizedString("OK", comment: "Livestream Not Available Dialog OK Button")
            let okAction = UIAlertAction(title: okTitle, style: .cancel, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
