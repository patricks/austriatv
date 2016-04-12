//
//  OverviewCollectionViewController.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 05.03.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import UIKit
import Kingfisher

class OverviewCollectionViewController: UICollectionViewController {
    
    private var activityIndicatorView: UIActivityIndicatorView!
    
    private let reuseCellIdentifier = "TeaserCell"
    private let reuseHeaderIdentifier = "TeaserHeader"
    
    private let apiManager = ApiManager()
    
    private var teasers = [Int: [Teaser]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingIndicator()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getDataFromServer()
    }
    
    // MARK: UI
    
    private func setupLoadingIndicator() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = AppConstants.red
        
        activityIndicatorView.startAnimating()
        
        self.view.addSubview(activityIndicatorView)
    }

    // MARK: Data Source
    
    private func getDataFromServer() {
        
        // highlights
        apiManager.getHighlights { (successful, teaserItems) in
            if successful {
                if let _ = teaserItems {
                    self.teasers[TeaserCategory.Hightlights.hashValue] = teaserItems!
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.collectionView!.reloadData()
                }
            }
        }
        
        // newest
        apiManager.getNewest { (successful, teaserItems) in
            if successful {
                if let _ = teaserItems {
                    self.teasers[TeaserCategory.Newest.hashValue] = teaserItems!
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.collectionView!.reloadData()
                }
            }
        }
        
        // most viewed
        apiManager.getMostViewed { (successful, teaserItems) in
            if successful {
                if let _ = teaserItems {
                    self.teasers[TeaserCategory.MostViewed.hashValue] = teaserItems!
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.collectionView!.reloadData()
                }
            }
        }
        
        // recommended
        apiManager.getRecommended { (successful, teaserItems) in
            if successful {
                if let _ = teaserItems {
                    self.teasers[TeaserCategory.Recommendations.hashValue] = teaserItems!
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.collectionView!.reloadData()
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEpisode" {
            if let indexPaths = collectionView!.indexPathsForSelectedItems() {
                if let indexPath = indexPaths.first {
                    if let teasers = teasers[indexPath.section] {
                        let teaser = teasers[indexPath.row]
                        
                        if let episodeId = teaser.episodeId {
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
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension OverviewCollectionViewController {

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return teasers.count
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let teasers = teasers[section] {
            return teasers.count
        }
        
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCellIdentifier, forIndexPath: indexPath) as! TeaserCollectionViewCell
        
        if let teasers = teasers[indexPath.section] {
            let teaser = teasers[indexPath.row]
            
            let placeholderImage = UIImage(named: "Overview_Placeholder")
            
            // Configure the cell
            if let imageURL = teaser.getImageURL() {
                cell.teaserImageView.kf_setImageWithURL(imageURL, placeholderImage: placeholderImage)
            } else {
                cell.teaserImageView.image = placeholderImage
            }
            
            if let title = teaser.title {
                cell.teaserTitle.text = title
            }
        }
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, forIndexPath: indexPath) as! OverviewCollectionHeaderView
            
            if let category = TeaserCategory(rawValue: indexPath.section) {
                headerView.titleLabel.text = category.description
            }
            
            reusableView = headerView
        } else {
            reusableView = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        }
        
        return reusableView
    }
}
