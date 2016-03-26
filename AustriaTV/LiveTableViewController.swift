//
//  LiveTableViewController.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.03.16.
//  Copyright © 2016 Patrick. All rights reserved.
//


import UIKit

class LiveTableViewController: UITableViewController {
    
    private let apiManager = ApiManager()
    
    private var episodes = [Episode]()
    
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
                    
                    //self.sortPrograms()
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Table view data source

extension LiveTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EpisodeCell", forIndexPath: indexPath)
        
        let episode = episodes[indexPath.row]
        
        cell.textLabel?.text = episode.title
        
        return cell
    }
}
