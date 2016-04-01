//
//  EpisodeDetailsViewController.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 28.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher

class EpisodeDetailsViewController: UIViewController {
    
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    
    private let apiManager = ApiManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // reset the labels
        episodeTitleLabel.text = nil
        durationLabel.text = nil
    }
    
    deinit {
        removeNotifications()
    }
    
    var episode: Episode? {
        didSet {
            setEpisode()
        }
    }
    
    // MARK: Episode
    
    private func setEpisode() {
        if let episode = episode {
            // load details if not already loaded
            switch episode.type {
            case .Short:
                updateEpisodeDetails()
            case .Detail:
                setEpisodeDetails()
                
                // enable play button
                playButton.enabled = true
            }
        }
    }
    
    private func updateEpisodeDetails() {
        if let episode = episode {
            if let episodeId = episode.episodeId {
                apiManager.getEpisode(episodeId, completion: { (successful, episode) in
                    if successful {
                        if let _ = episode {
                            self.episode = episode!
                        }
                    }
                })
            }
        }
    }
    
    private func setEpisodeDetails() {
        if let episode = episode {
            if episodeTitleLabel != nil {
                episodeTitleLabel.text = episode.title
            }
            
            let placeholderImage = UIImage(named: "Episode_Details_Placeholder")
            
            if let imageURL = episode.getFullImageURL() {
                if episodeImageView != nil {
                    episodeImageView.kf_setImageWithURL(imageURL, placeholderImage: placeholderImage)
                }
            } else {
                episodeImageView.image = placeholderImage
            }
            
            if let duration = episode.getFormatedDuration() {
                if episode.duration! > 0 {
                    durationLabel.text = duration
                }
            }
        }
    }
    
    // MARK: - Notifications
    
    private func removeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(AVPlayerItemDidPlayToEndTimeNotification)
    }
    
    func playerDidFinishPlaying(notification: NSNotification) {
        Log.debug(#function)
        self.dismissViewControllerAnimated(true) { () -> Void in
            Log.debug("Back from player view")
        }
    }
    
    // MARK: UI
    
    @IBAction func playButtonPushed(sender: AnyObject) {
        if let _ = episode {
            playEpisode(episode!)
        }
    }
    
    // MARK: Play Video
    
    private func playEpisode(episode: Episode) {
        
        var urls = [String]()
        var avPlayerItems = [AVPlayerItem]()
        
        if let segments = episode.segments {
            for segment in segments {
                if let videos = segment.videos {
                    for video in videos {
                        if let streamingURL = video.streamingURL {
                            if isHttpMp4URL(streamingURL) {
                                Log.debug("URL: \(streamingURL)")
                                
                                urls.append(streamingURL)
                                
                                if let url = NSURL(string: streamingURL) {
                                    let item = AVPlayerItem(URL: url)
                                    
                                    var metadataItems = [AVMetadataItem]()
                                    
                                    // title
                                    if let title = episode.title {
                                        let titleMetadata = AVMutableMetadataItem()
                                        titleMetadata.identifier = AVMetadataCommonIdentifierTitle
                                        titleMetadata.locale = NSLocale.currentLocale()
                                        titleMetadata.value = title
                                        
                                        metadataItems.append(titleMetadata)
                                    }
                                    
                                    // description
                                    if let description = episode.getFullDescription() {
                                        let descriptionMetadata = AVMutableMetadataItem()
                                        descriptionMetadata.identifier = AVMetadataCommonIdentifierDescription
                                        descriptionMetadata.locale = NSLocale.currentLocale()
                                        descriptionMetadata.value = description
                                        
                                        metadataItems.append(descriptionMetadata)
                                    }
                                    
                                    // artwork
                                    if let image = episodeImageView.image {
                                        let artworkMetadata = AVMutableMetadataItem()
                                        artworkMetadata.identifier = AVMetadataCommonIdentifierArtwork
                                        artworkMetadata.locale = NSLocale.currentLocale()
                                        artworkMetadata.value = UIImageJPEGRepresentation(image, 1)
                                        
                                        metadataItems.append(artworkMetadata)
                                    }
                                    
                                    item.externalMetadata = metadataItems
                                    
                                    avPlayerItems.append(item)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if avPlayerItems.count > 0 {
            Log.debug("Segments: \(avPlayerItems.count)")
            playVideos(avPlayerItems)
        }
    }
    
    private func isHttpMp4URL(streamingURL: String) -> Bool {
        if streamingURL.rangeOfString("mp4") != nil {
            if streamingURL.rangeOfString("http://") != nil {
                return true
            }
        }
        
        return false
    }
    
    private func playVideos(items: [AVPlayerItem]) {
        let avPlayerController = AVPlayerViewController()
        
        let player = AVQueuePlayer(items: items)
        
        // get notification if last segment has finished playing
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(EpisodeDetailsViewController.playerDidFinishPlaying(_:)),
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player.items().last)
        
        avPlayerController.player = player
        
        self.presentViewController(avPlayerController, animated: true, completion: { () -> Void in
            player.play()
        })
    }
}
