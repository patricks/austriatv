//
//  LiveCollectionViewController.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.03.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import UIKit
import Kingfisher
import Crashlytics

class LiveCollectionViewController: UICollectionViewController {
    
    private var activityIndicatorView: UIActivityIndicatorView!
    
    private let reuseCellIdentifier = "TeaserCell"
    private let reuseHeaderIdentifier = "TeaserHeader"
    
    private let apiManager = ApiManager()
    
    private var sortedChannels = [(String, [Episode])]()
    
    private var reloadTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingIndicator()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getDataFromServer()
        
        // analytics
        Answers.logCustomEventWithName("ViewController", customAttributes: ["ViewControllerSelected": "LiveCollectionViewController"])
    }
    
    private func setupLoadingIndicator() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = AppConstants.ActivityIndicatorColor
        
        activityIndicatorView.startAnimating()
        
        self.view.addSubview(activityIndicatorView)
    }
    
    // MARK: Data Source
    
    private func getDataFromServer() {
        
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
    
    private func parseChannels(episodes: [Episode]) -> [(String, [Episode])] {
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
        return channels.sort { $0.0 < $1.0 }
    }
    
    private func setDurationForServerReload(seconds: Double) {
        reloadTimer.invalidate()
        reloadTimer = NSTimer.scheduledTimerWithTimeInterval(
            seconds,
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
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let episodes = sortedChannels[indexPath.section].1
        let episode = episodes[indexPath.row]
        
        if episode.isLiveStreamOnline() {
            performSegueWithIdentifier("ShowEpisode", sender: self)
        } else {
            var message = NSLocalizedString("Livestream is currently not available", comment: "Livestream Not Available Dialog Unknown Time")
            
            if let duration = episode.getFormatedDurationToLiveStreamStart() {
                message = String.localizedStringWithFormat(NSLocalizedString("Livestream is available in %@", comment: "Livestream Not Available Dialog Message"), duration)
            }
            
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            
            let okTitle = NSLocalizedString("OK", comment: "Livestream Not Available Dialog OK Button")
            let okAction = UIAlertAction(title: okTitle, style: .Cancel, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
