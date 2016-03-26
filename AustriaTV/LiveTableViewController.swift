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
                    
                    self.tableView.reloadData()
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

// MARK: - Table view data source

extension LiveTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedChannels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EpisodeCell", forIndexPath: indexPath)
        
        let channel = sortedChannels[indexPath.row]
        
        cell.textLabel?.text = channel.0
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let nextFocusedView = context.nextFocusedView where nextFocusedView.isDescendantOfView(tableView) else { return }
        guard let indexPath = context.nextFocusedIndexPath else { return }
        
        let channel = sortedChannels[indexPath.row]
        
        for episode in channel.1 {
            
            Log.debug("title: \(episode.title) state: \(episode.publishState)")
        }
        
     
        /*
        delayedSeguesOperationQueue.cancelAllOperations()
        
        let performSegueOperation = NSBlockOperation()
        
        performSegueOperation.addExecutionBlock { [weak self] in
            // Pause the block so the segue isn't immediately performed.
            NSThread.sleepForTimeInterval(ProgramsTableViewController.performSegueDelay)
            
            guard !performSegueOperation.cancelled else { return }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if let program = self?.programs[indexPath.row] {
                    self?.setupDetailsViewWithProgram(program)
                }
            }
        }
        
        delayedSeguesOperationQueue.addOperation(performSegueOperation)
        */
    }
}
