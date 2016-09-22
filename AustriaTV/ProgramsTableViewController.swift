//
//  ProgramsTableViewController.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 27.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ProgramsTableViewController: UITableViewController {
    
    @IBOutlet weak var programFilterSegmentedControl: UISegmentedControl!
    
    fileprivate var activityIndicatorView: UIActivityIndicatorView!
    
    fileprivate let apiManager = ApiManager()
    
    fileprivate var allPrograms = [Program]()
    fileprivate var visiblePrograms = [Program]()
    fileprivate var favoritePrograms = [Program]()
    
    fileprivate let delayedSeguesOperationQueue = OperationQueue()
    fileprivate static let performSegueDelay: TimeInterval = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visiblePrograms = allPrograms
        
        setupNotifications()
        getDataFromServer()
        getStoredPrograms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if activityIndicatorView == nil {
            setupUI()
        }
        
        if visiblePrograms.count < 1 {
            activityIndicatorView.startAnimating()
        }
    }
    
    // MARK: UI
    
    fileprivate func setupUI() {
        self.navigationItem.title = NSLocalizedString("Programs", comment: "ProgramsTableViewController - Title")
        /*
         self.navigationController?.navigationBar.titleTextAttributes = [
         NSForegroundColorAttributeName : UIColor.whiteColor(),
         NSFontAttributeName: UIFont.systemFontOfSize(50)
         ]
         */
        
        self.navigationItem.title = nil
        self.tableView.mask = nil
        
        setupLoadingIndicator()
    }
    
    fileprivate func setupLoadingIndicator() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = AppConstants.ActivityIndicatorColor
        
        self.view.addSubview(activityIndicatorView)
    }
    
    @IBAction func programFilterChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            getStoredPrograms()
            
            visiblePrograms = favoritePrograms
        default:
            visiblePrograms = allPrograms
        }
        
        tableView.reloadData()
    }
    
    // MARK: Data Source
    
    fileprivate func getStoredPrograms() {
        if let favorites = SettingsManager.sharedInstance.favoritePrograms {
            favoritePrograms = Array(favorites)
        }
    }
    
    fileprivate func getDataFromServer() {
        apiManager.getPrograms { (successful, programs) in
            if successful {
                if let _ = programs {
                    self.allPrograms = programs!
                    
                    self.sortPrograms()
                    
                    // if this program filter is selected, copy the array
                    if self.programFilterSegmentedControl.selectedSegmentIndex == 0 {
                        self.visiblePrograms = self.allPrograms
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    fileprivate func sortPrograms() {
        let sorted = allPrograms.sorted { $0.name < $1.name }
        
        allPrograms = sorted
    }
    
    // MARK: - Notifications
    
    fileprivate func setupNotifications() {
        // get notifications for if beacons updates appear
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(ProgramsTableViewController.onFavoritesUpdated(_:)),
                                                         name: NSNotification.Name(rawValue: AppConstants.FavoritesUpdatedKey),
                                                         object: nil)
    }
    
    func onFavoritesUpdated(_ notification: Notification) {
        
        if programFilterSegmentedControl.selectedSegmentIndex == 1 {
            getStoredPrograms()
            
            visiblePrograms = favoritePrograms
            self.tableView.reloadData()
        }
    }
    
    // MARK: Manage DetailsView
    
    fileprivate func setupDetailsViewWithProgram(_ program: Program) {
        if let childNavigationController = self.splitViewController?.viewControllers.last as? UINavigationController {
            if let childViewController = childNavigationController.viewControllers.first as? ProgramDetailsViewController {
                childViewController.program = program
            }
        }
    }
}

// MARK: - Table view data source

extension ProgramsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if visiblePrograms.count == 0 {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
        
        return visiblePrograms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgramCell", for: indexPath)
        
        let program = visiblePrograms[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = program.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        // change the text color of the selected cell
        if let previousIndexPath = context.previouslyFocusedIndexPath {
            if let previousCell = tableView.cellForRow(at: previousIndexPath) {
                previousCell.textLabel?.textColor = UIColor.white
            }
        }
        
        guard let nextFocusedView = context.nextFocusedView , nextFocusedView.isDescendant(of: tableView) else { return }
        guard let indexPath = context.nextFocusedIndexPath else { return }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.textLabel?.textColor = AppConstants.Blue
        }
        
        delayedSeguesOperationQueue.cancelAllOperations()
        
        let performSegueOperation = BlockOperation()
        
        performSegueOperation.addExecutionBlock { [weak self] in
            // Pause the block so the segue isn't immediately performed.
            Thread.sleep(forTimeInterval: ProgramsTableViewController.performSegueDelay)
            
            guard !performSegueOperation.isCancelled else { return }
            
            OperationQueue.main.addOperation {
                if let program = self?.visiblePrograms[(indexPath as NSIndexPath).row] {
                    self?.setupDetailsViewWithProgram(program)
                }
            }
        }
        
        delayedSeguesOperationQueue.addOperation(performSegueOperation)
    }
}

