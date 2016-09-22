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
    
    fileprivate let apiManager = ApiManager()
    
    fileprivate var episodes = [Episode]()
    
    var program: Program? {
        didSet {
            setProgram()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // clear the view
        programNameLabel.text = ""
        favoriteButton.isHidden = true
    }
    
    fileprivate func setProgram() {
        if let program = program {
            programNameLabel.text = program.name
            favoriteButton.isHidden = false
            
            // set favorite button
            setFavoriteButtonState()
            
            let placeholderImage = UIImage(named: "Episode_Details_Placeholder")
            
            if let imageURL = program.getImageURL() {
                programImageView.kf.setImage(with: imageURL, placeholder: placeholderImage)
            } else {
                programImageView.image = placeholderImage
            }
            
            getDataFromServer()
        }
    }
    
    fileprivate func setFavoriteButtonState() {
        if let program = program {
            if SettingsManager.sharedInstance.isFavoriteProgam(program) {
                favoriteButton.setImage(UIImage(named: "Button_Heart_Selected"), for: UIControlState())
            } else {
                favoriteButton.setImage(UIImage(named: "Button_Heart"), for: UIControlState())
            }
        }
    }
    
    // MARK: Data Source
    
    fileprivate func getDataFromServer() {
        if let programId = program?.programId {
            
            apiManager.getEpisodeByProgram(programId, completion: { (successful, episodes) in
                if successful {
                    if let _ = episodes {
                        self.episodes = episodes!
                        self.episodeTableView.reloadData()
                    }
                }
            })
        }
    }
    
    @IBAction func favoriteButtonPushed(_ sender: AnyObject) {
        if let program = program {
            
            if SettingsManager.sharedInstance.isFavoriteProgam(program) {
                SettingsManager.sharedInstance.removeFavoriteProgram(program)
            } else {
                SettingsManager.sharedInstance.addFavoriteProgram(program)
            }
            
            // set favorite button
            setFavoriteButtonState()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEpisode" {
            if let indexPath = episodeTableView.indexPathForSelectedRow {
                let episode = episodes[(indexPath as NSIndexPath).row]
                
                if let viewController = segue.destination as? EpisodeDetailsViewController {
                    viewController.episode = episode
                }
            }
        }
    }
}

extension ProgramDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath)
        
        let episode = episodes[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = episode.getFormatedTitle()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowEpisode", sender: self)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if episodes.count > 0 {
            return NSLocalizedString("Episodes", comment: "ProgramDetailsViewController: Episodes Title For Header")
        }
        
        return nil
    }
}
