//
//  ProgramDetailsViewController.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 27.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import UIKit
import Kingfisher

class ProgramDetailsViewController: UIViewController {
    
    @IBOutlet weak var programNameLabel: UILabel!
    @IBOutlet weak var episodeTableView: UITableView!
    @IBOutlet weak var programImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    private let apiManager = ApiManager()
    
    private var episodes = [Episode]()
    
    var program: Program? {
        didSet {
            setProgram()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // clear the view
        programNameLabel.text = ""
        favoriteButton.hidden = true
    }
    
    private func setProgram() {
        if let program = program {
            programNameLabel.text = program.name
            
            let placeholderImage = UIImage(named: "Episode_Details_Placeholder")
            
            if let imageURL = program.getImageURL() {
                programImageView.kf_setImageWithURL(imageURL, placeholderImage: placeholderImage)
            } else {
                programImageView.image = placeholderImage
            }
            
            getDataFromServer()
        }
    }
    
    // MARK: Data Source
    
    private func getDataFromServer() {
        if let programId = program?.programId {
            apiManager.getEpisodeByProgram(programId, completion: { (successful, episodes) -> () in
                if successful {
                    if let _ = episodes {
                        self.episodes = episodes!
                        self.episodeTableView.reloadData()
                    }
                }
            })
        }
    }
    
    @IBAction func favoriteButtonPushed(sender: AnyObject) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEpisode" {
            if let indexPath = episodeTableView.indexPathForSelectedRow {
                let episode = episodes[indexPath.row]
                
                if let viewController = segue.destinationViewController as? EpisodeDetailsViewController {
                    viewController.episode = episode
                }
            }
        }
    }
}

extension ProgramDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EpisodeCell", forIndexPath: indexPath)
        
        let episode = episodes[indexPath.row]
        
        cell.textLabel?.text = episode.getFormatedTitle()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowEpisode", sender: self)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if episodes.count > 0 {
            return NSLocalizedString("Episodes", comment: "ProgramDetailsViewController: Episodes Title For Header")
        }
        
        return nil
    }
}
