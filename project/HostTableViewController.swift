//
//  HostTableViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/8/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import CoreData

class HostTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating  {
    
    @IBOutlet weak var addHostButton: UIBarButtonItem!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var searchController: UISearchController!
    var searchPredicate: NSPredicate!
    var filteredData: [Host]? = nil
    var oldButton:UIBarButtonItem? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "uTexas Events"
        definesPresentationContext = true
        
        oldButton = self.navigationItem.rightBarButtonItem!
        self.navigationItem.rightBarButtonItem = nil
        
        searchController = ({
            let controllerSearch = UISearchController(searchResultsController: nil)
            controllerSearch.delegate = self
            controllerSearch.searchBar.delegate = self
            controllerSearch.hidesNavigationBarDuringPresentation = true
            controllerSearch.definesPresentationContext = false
            controllerSearch.dimsBackgroundDuringPresentation = false
            controllerSearch.searchBar.sizeToFit()
            controllerSearch.searchResultsUpdater = self
            controllerSearch.searchBar.placeholder = "Search by name of host"
            self.tableView.tableHeaderView = controllerSearch.searchBar
            return controllerSearch
        })()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!Config.isAdmin) {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = oldButton
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchPredicate == nil {
            return self.fetchedResultsController.sections!.count
        } else {
            return 1 ?? 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchPredicate == nil {
            let sections = self.fetchedResultsController.sections
            let sectionInfo = sections![section]
            return sectionInfo.numberOfObjects
        } else {
            return filteredData?.count ?? 0
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HostCell", forIndexPath: indexPath)
        if searchPredicate == nil {
            self.configureCell(cell, atIndexPath: indexPath)
            
        } else {
            if let filteredSearch = filteredData?[indexPath.row] {
                cell.textLabel?.text = filteredSearch.name
            }
        }
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let host = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Host
        cell.textLabel!.text = host.name
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (!Config.isAdmin) {
            return false
        }
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let context = self.fetchedResultsController.managedObjectContext
        let backup = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        context.deleteObject(backup)
        do {
            try context.save()
        } catch {
            context.insertObject(backup)
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title: "Error", message: "Host can't be removed without deleting all events belong to the host.", preferredStyle: UIAlertControllerStyle.Alert)
                
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action:UIAlertAction) in
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true, completion:nil)
            }
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Host", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let dateSort = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [dateSort]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "host")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AddHost") {
            let view = segue.destinationViewController as! AddNewHostViewController
            view.managedObjectContext = managedObjectContext
        } else if (segue.identifier == "HostDetail") {
            let view = segue.destinationViewController as! HostDetailViewController
            let index = self.tableView.indexPathForSelectedRow!
            view.host = self.fetchedResultsController.objectAtIndexPath(index) as? Host
            //searchController.active = false
        }
        // Set up the Back button
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText != nil {
            searchPredicate = NSPredicate(format: "name contains[c] %@", searchText!)
            filteredData = fetchedResultsController.fetchedObjects!.filter() {
                return self.searchPredicate.evaluateWithObject($0)
                } as? [Host]
            self.tableView.reloadData()
        }
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(searchController)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchPredicate = nil
        filteredData = nil
        self.tableView.reloadData()
    }
}
