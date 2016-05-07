//
//  ProgramsTableViewController.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 27.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import UIKit
import Crashlytics

class ProgramsTableViewController: UITableViewController {
    
    @IBOutlet weak var programFilterSegmentedControl: UISegmentedControl!
    
    private var activityIndicatorView: UIActivityIndicatorView!
    
    private let apiManager = ApiManager()
    
    private var allPrograms = [Program]()
    private var visiblePrograms = [Program]()
    private var favoritePrograms = [Program]()
    
    private let delayedSeguesOperationQueue = NSOperationQueue()
    private static let performSegueDelay: NSTimeInterval = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visiblePrograms = allPrograms
        
        setupNotifications()
        getDataFromServer()
        getStoredPrograms()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if activityIndicatorView == nil {
            setupUI()
        }
        
        if visiblePrograms.count < 1 {
            activityIndicatorView.startAnimating()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // analytics
        Answers.logCustomEventWithName("ViewController", customAttributes: ["ViewControllerSelected": "ProgramsTableViewController"])
    }
    
    deinit {
        removeNotifications()
    }
    
    // MARK: UI
    
    private func setupUI() {
        self.navigationItem.title = NSLocalizedString("Programs", comment: "ProgramsTableViewController - Title")
        /*
         self.navigationController?.navigationBar.titleTextAttributes = [
         NSForegroundColorAttributeName : UIColor.whiteColor(),
         NSFontAttributeName: UIFont.systemFontOfSize(50)
         ]
         */
        
        self.navigationItem.title = nil
        self.tableView.maskView = nil
        
        setupLoadingIndicator()
    }
    
    private func setupLoadingIndicator() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = AppConstants.ActivityIndicatorColor
        
        self.view.addSubview(activityIndicatorView)
    }
    
    @IBAction func programFilterChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            getStoredPrograms()
            
            visiblePrograms = favoritePrograms
            
            // analytics
            Answers.logCustomEventWithName("ProgramFilter", customAttributes: ["FilterSelected": "Favorites"])
        default:
            visiblePrograms = allPrograms
            
            // analytics
            Answers.logCustomEventWithName("ProgramFilter", customAttributes: ["FilterSelected": "All"])
        }
        
        tableView.reloadData()
    }
    
    // MARK: Data Source
    
    private func getStoredPrograms() {
        if let favorites = SettingsManager.sharedInstance.favoritePrograms {
            favoritePrograms = Array(favorites)
        }
    }
    
    private func getDataFromServer() {
        apiManager.getPrograms { (successful, programs) in
            if successful {
                if let _ = programs {
                    self.allPrograms = programs!
                    
                    self.sortPrograms()
                    
                    // if this program filter is selected, copy the array
                    if self.programFilterSegmentedControl.selectedSegmentIndex == 0 {
                        self.visiblePrograms = self.allPrograms
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    private func sortPrograms() {
        let sorted = allPrograms.sort { $0.name < $1.name }
        
        allPrograms = sorted
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        // get notifications for if beacons updates appear
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ProgramsTableViewController.onFavoritesUpdated(_:)),
                                                         name: AppConstants.favoritesUpdatedKey,
                                                         object: nil)
    }
    
    private func removeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(AppConstants.favoritesUpdatedKey)
    }
    
    func onFavoritesUpdated(notification: NSNotification) {
        
        if programFilterSegmentedControl.selectedSegmentIndex == 1 {
            getStoredPrograms()
            
            visiblePrograms = favoritePrograms
            self.tableView.reloadData()
        }
    }
    
    // MARK: Manage DetailsView
    
    private func setupDetailsViewWithProgram(program: Program) {
        if let childNavigationController = self.splitViewController?.viewControllers.last as? UINavigationController {
            if let childViewController = childNavigationController.viewControllers.first as? ProgramDetailsViewController {
                childViewController.program = program
            }
        }
    }
}

// MARK: - Table view data source

extension ProgramsTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if visiblePrograms.count == 0 {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
        
        return visiblePrograms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProgramCell", forIndexPath: indexPath)
        
        let program = visiblePrograms[indexPath.row]
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.text = program.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let nextFocusedView = context.nextFocusedView where nextFocusedView.isDescendantOfView(tableView) else { return }
        guard let indexPath = context.nextFocusedIndexPath else { return }
        
        delayedSeguesOperationQueue.cancelAllOperations()
        
        let performSegueOperation = NSBlockOperation()
        
        performSegueOperation.addExecutionBlock { [weak self] in
            // Pause the block so the segue isn't immediately performed.
            NSThread.sleepForTimeInterval(ProgramsTableViewController.performSegueDelay)
            
            guard !performSegueOperation.cancelled else { return }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if let program = self?.visiblePrograms[indexPath.row] {
                    self?.setupDetailsViewWithProgram(program)
                }
            }
        }
        
        delayedSeguesOperationQueue.addOperation(performSegueOperation)
    }
}

