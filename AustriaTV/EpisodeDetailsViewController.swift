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
    
    fileprivate let apiManager = ApiManager()
    
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
    
    fileprivate func setEpisode() {
        if let episode = episode {
            // load details if not already loaded
            switch episode.type {
            case .short:
                updateEpisodeDetails()
            case .detail:
                setEpisodeDetails()
                
                // enable play button
                playButton.isEnabled = true
            }
        }
    }
    
    fileprivate func updateEpisodeDetails() {
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
    
    fileprivate func setEpisodeDetails() {
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
    
    fileprivate func removeNotifications() {
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
    }
    
    func playerDidFinishPlaying(_ notification: Notification) {
        Log.debug(#function)
        self.dismiss(animated: true) { () -> Void in
            Log.debug("Back from player view")
        }
    }
    
    // MARK: UI
    
    @IBAction func playButtonPushed(_ sender: AnyObject) {
        if let _ = episode {
            playEpisode(episode!)
        }
    }
    
    // MARK: Play Video
    
    fileprivate func playEpisode(_ episode: Episode) {
        
        if let episodeType = episode.episodeType {
            switch episodeType {
            case .videoOnDemand:
                playVideoOnDemandEpisode(episode)
            case .livestream:
                playLivestreamEpisode(episode)
            }
        }
    }
    
    fileprivate func playLivestreamEpisode(_ episode: Episode) {
        var avPlayerItems = [AVPlayerItem]()
        
        if let videos = episode.livestreamingVideos {
            avPlayerItems = prepareForPlayback(videos, forEpisode: episode)
        }
        
        if avPlayerItems.count > 0 {
            Log.debug("Segments: \(avPlayerItems.count)")
            playVideos(avPlayerItems)
        }
    }
    
    fileprivate func playVideoOnDemandEpisode(_ episode: Episode) {
        var avPlayerItems = [AVPlayerItem]()
        
        if let segments = episode.segments {
            for segment in segments {
                if let videos = segment.videos {
                    avPlayerItems.append(contentsOf: prepareForPlayback(videos, forEpisode: episode))
                }
            }
        }
        
        if avPlayerItems.count > 0 {
            Log.debug("Segments: \(avPlayerItems.count)")
            playVideos(avPlayerItems)
        }
    }
    
    fileprivate func prepareForPlayback(_ videos: [Video], forEpisode episode: Episode) -> [AVPlayerItem] {
        var avPlayerItems = [AVPlayerItem]()
        
        for video in videos {
            if let streamingURL = video.streamingURL {
                if let episodeType = episode.episodeType {
                    if isHttpMp4URL(streamingURL, type: episodeType) {
                        Log.debug("URL: \(streamingURL)")
                        
                        if let url = URL(string: streamingURL) {
                            let item = AVPlayerItem(url: url)
                            
                            var metadataItems = [AVMetadataItem]()
                            
                            // title
                            if let title = episode.title {
                                let titleMetadata = AVMutableMetadataItem()
                                titleMetadata.identifier = AVMetadataCommonIdentifierTitle
                                titleMetadata.locale = Locale.current
                                titleMetadata.value = title as (NSCopying & NSObjectProtocol)?
                                
                                metadataItems.append(titleMetadata)
                            }
                            
                            // description
                            if let description = episode.getFullDescription() {
                                let descriptionMetadata = AVMutableMetadataItem()
                                descriptionMetadata.identifier = AVMetadataCommonIdentifierDescription
                                descriptionMetadata.locale = Locale.current
                                descriptionMetadata.value = description as (NSCopying & NSObjectProtocol)?
                                
                                metadataItems.append(descriptionMetadata)
                            }
                            
                            // artwork
                            if let image = episodeImageView.image {
                                let artworkMetadata = AVMutableMetadataItem()
                                artworkMetadata.identifier = AVMetadataCommonIdentifierArtwork
                                artworkMetadata.locale = Locale.current
                                artworkMetadata.value = UIImageJPEGRepresentation(image, 1) as (NSCopying & NSObjectProtocol)?
                                
                                metadataItems.append(artworkMetadata)
                            }
                            
                            item.externalMetadata = metadataItems
                            
                            avPlayerItems.append(item)
                        }
                    }
                }
            }
        }
        
        return avPlayerItems
    }
    
    fileprivate func isHttpMp4URL(_ streamingURL: String, type: Episode.EpisodeType) -> Bool {
        switch type {
        case .livestream:
            return isHttpMP4LiveStreamingURL(streamingURL)
        case .videoOnDemand:
            return isOnDemandMP4StreamingURL(streamingURL)
        }
    }
    
    fileprivate func isOnDemandMP4StreamingURL(_ streamingURL: String) -> Bool {
        if streamingURL.range(of: "mp4") != nil {
            if streamingURL.range(of: "http://") != nil {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func isHttpMP4LiveStreamingURL(_ streamingURL: String) -> Bool {
        if streamingURL.range(of: "playlist.m3u8") != nil {
            if streamingURL.range(of: "_q4a") != nil {
                if streamingURL.range(of: "ipad") != nil {
                    return true
                }
            }
        }
        
        return false
    }
    
    fileprivate func playVideos(_ items: [AVPlayerItem]) {
        let avPlayerController = AVPlayerViewController()
        
        let player = AVQueuePlayer(items: items)
        
        // get notification if last segment has finished playing
        NotificationCenter.default.addObserver(self,
            selector: #selector(EpisodeDetailsViewController.playerDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.items().last)
        
        avPlayerController.player = player
        
        self.present(avPlayerController, animated: true, completion: { () -> Void in
            player.play()
        })
    }
}
