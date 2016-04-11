//
//  ProgramsTableViewController.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 27.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import UIKit

class ProgramsTableViewController: UITableViewController {
    
    private let apiManager = ApiManager()
    
    private var programs = [Program]()
    
    private let delayedSeguesOperationQueue = NSOperationQueue()
    private static let performSegueDelay: NSTimeInterval = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Programs", comment: "ProgramsTableViewController - Title")
        /*
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(50)
        ]
        */
        
        self.navigationItem.title = nil
        self.tableView.maskView = nil
        
        getDataFromServer()
    }
    
    // MARK: Data Source
    
    private func getDataFromServer() {
        apiManager.getPrograms { (successful, programs) in
            if successful {
                if let _ = programs {
                    self.programs = programs!
                    
                    self.sortPrograms()
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func sortPrograms() {
        let sorted = programs.sort { $0.name < $1.name }
        
        programs = sorted
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
        return programs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProgramCell", forIndexPath: indexPath)
        
        let program = programs[indexPath.row]
        
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
                if let program = self?.programs[indexPath.row] {
                    self?.setupDetailsViewWithProgram(program)
                }
            }
        }
        
        delayedSeguesOperationQueue.addOperation(performSegueOperation)
    }
}

