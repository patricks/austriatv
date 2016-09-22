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
    
    fileprivate var activityIndicatorView: UIActivityIndicatorView!
    
    fileprivate let reuseCellIdentifier = "TeaserCell"
    fileprivate let reuseHeaderIdentifier = "TeaserHeader"
    
    fileprivate let apiManager = ApiManager()
    
    fileprivate var teasers = [Int: [Teaser]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getDataFromServer()
    }
    
    // MARK: UI
    
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
        
        // highlights
        apiManager.getHighlights { (successful, teaserItems) in
            if successful {
                if let _ = teaserItems {
                    self.teasers[TeaserCategory.hightlights.hashValue] = teaserItems!
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.collectionView!.reloadData()
                }
            }
        }
        
        // newest
        apiManager.getNewest { (successful, teaserItems) in
            if successful {
                if let _ = teaserItems {
                    self.teasers[TeaserCategory.newest.hashValue] = teaserItems!
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.collectionView!.reloadData()
                }
            }
        }
        
        // most viewed
        apiManager.getMostViewed { (successful, teaserItems) in
            if successful {
                if let _ = teaserItems {
                    self.teasers[TeaserCategory.mostViewed.hashValue] = teaserItems!
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.collectionView!.reloadData()
                }
            }
        }
        
        // recommended
        apiManager.getRecommended { (successful, teaserItems) in
            if successful {
                if let _ = teaserItems {
                    self.teasers[TeaserCategory.recommendations.hashValue] = teaserItems!
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.collectionView!.reloadData()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEpisode" {
            if let indexPaths = collectionView!.indexPathsForSelectedItems {
                if let indexPath = indexPaths.first {
                    if let teasers = teasers[(indexPath as NSIndexPath).section] {
                        let teaser = teasers[(indexPath as NSIndexPath).row]
                        
                        if let episodeId = teaser.episodeId {
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
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension OverviewCollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return teasers.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let teasers = teasers[section] {
            return teasers.count
        }
        
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellIdentifier, for: indexPath) as! TeaserCollectionViewCell
        
        if let teasers = teasers[(indexPath as NSIndexPath).section] {
            let teaser = teasers[(indexPath as NSIndexPath).row]
            
            let placeholderImage = UIImage(named: "Overview_Placeholder")
            
            // Configure the cell
            if let imageURL = teaser.getImageURL() {
                cell.teaserImageView.kf.setImage(with: imageURL, placeholder: placeholderImage)
            } else {
                cell.teaserImageView.image = placeholderImage
            }
            
            if let title = teaser.title {
                cell.teaserTitle.text = title
            }
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath) as! OverviewCollectionHeaderView
            
            if let category = TeaserCategory(rawValue: (indexPath as NSIndexPath).section) {
                headerView.titleLabel.text = category.description
            }
            
            reusableView = headerView
        } else {
            reusableView = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        
        return reusableView
    }
}
