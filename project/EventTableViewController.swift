//
//  EventTableViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/3/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import CoreData
import Parse

class EventTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, StoreCoreDataProtocol, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UIPopoverPresentationControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var searchController: UISearchController!
    var searchPredicate: NSPredicate!
    var filteredData: [Event]? = nil
    var activeSearch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up the navigation bar
        navigationItem.title = "uTexas Events"
        navigationController!.navigationBar.barTintColor = UIColor.orangeColor()
    
        definesPresentationContext = true

        NSFetchedResultsController.deleteCacheWithName(nil)
        
        //checks internet connection
        let connected = Reachability.isConnectedToNetwork()
        
        if (!connected) {
            let actionSheetController: UIAlertController = UIAlertController(title: "Connection Error", message: "Phone is not connected to internet. Please try again later.", preferredStyle: .ActionSheet)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
        
        
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        // Keep log in old account
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            Config.didLogIn = true
            if (currentUser!["isAdmin"] as! Bool) {
                Config.isAdmin = true
                print("Admin")
                self.navigationItem.leftBarButtonItem?.title = "Log out"
                self.navigationItem.leftBarButtonItem?.enabled = true
                self.navigationItem.rightBarButtonItem?.title = "Add Event"
                self.navigationItem.rightBarButtonItem?.enabled = true
            } else {
                self.navigationItem.leftBarButtonItem!.title = "RSVPs"
                self.navigationItem.leftBarButtonItem!.tintColor = UIColor.darkGrayColor()
                self.navigationItem.leftBarButtonItem?.enabled = false
                self.navigationItem.rightBarButtonItem?.title = "Log out"
                self.navigationItem.rightBarButtonItem?.enabled = true
                if (Config.RSVPList != nil) {
                    self.navigationItem.leftBarButtonItem!.title = "RSVPs"
                    dispatch_async(dispatch_get_main_queue()) {
                        self.navigationItem.leftBarButtonItem!.tintColor = nil
                    }
                    self.navigationItem.leftBarButtonItem?.enabled = true
                }
            }
        }
        
        // Configure the Search Controller
        searchController = ({
            let controllerSearch = UISearchController(searchResultsController: nil)
            controllerSearch.delegate = self
            controllerSearch.searchBar.delegate = self
            controllerSearch.hidesNavigationBarDuringPresentation = true
            controllerSearch.definesPresentationContext = false
            controllerSearch.dimsBackgroundDuringPresentation = false
            controllerSearch.searchBar.sizeToFit()
            controllerSearch.searchResultsUpdater = self
            controllerSearch.searchBar.placeholder = "Search by name of event"
            self.tableView.tableHeaderView = controllerSearch.searchBar
            return controllerSearch
        })()
        
        // Refreshing
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("update"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    func update() {
        NSNotificationCenter.defaultCenter().postNotificationName("updateCoreData", object: nil, userInfo: nil)
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
        refreshControl?.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchPredicate = nil
        filteredData = nil
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logIn_RSVP_Action(sender: AnyObject) {
        if (Config.didLogIn) {
            if (Config.isAdmin) {
                logout()
            } else {
                self.performSegueWithIdentifier("RSVPsListSegue", sender: self)
            }
        } else {
            self.performSegueWithIdentifier("popoverSegue", sender: self)
        }
    }
    
    @IBAction func logout_AddEvent_Action(sender: AnyObject) {
        if (Config.didLogIn && !Config.isAdmin) {
            logout()
        } else {
            self.performSegueWithIdentifier("AddEvent", sender: self)
        }
    }
    
    func logout() {
        PFUser.logOut()
        Config.RSVPList = nil
        Config.isAdmin = false
        Config.didLogIn = false
        
        self.navigationItem.leftBarButtonItem!.title = "Log in"
        self.navigationItem.leftBarButtonItem?.enabled = true
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem!.tintColor = nil
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchPredicate == nil {
            return self.fetchedResultsController.sections!.count
        } else {
            return 1
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
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath)
        if searchPredicate == nil {
            self.configureCell(cell, atIndexPath: indexPath)
            
        } else {
            if let filteredSearch = filteredData?[indexPath.row] {
                cell.textLabel?.text = filteredSearch.title
            }
        }
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let event = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Event
        cell.textLabel!.text = event.title
        cell.detailTextLabel!.text = event.host?.name
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (!activeSearch) {
            let sections = self.fetchedResultsController.sections
            let sectionInfo = sections![section]
            let event = sectionInfo.objects![0] as! Event
            print(event.dateSort)
            return  event.date
        } else {
            return ""
        }
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
        let event = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Event
        print(event.eventID)
        let query = PFQuery(className:"Events")
        query.getObjectInBackgroundWithId(event.eventID!) {
            (eventP: PFObject?, error: NSError?) -> Void in
            if error == nil && eventP != nil {
                context.deleteObject(event)
                do {
                    try context.save()
                    eventP?.deleteInBackground()
                } catch {
                    print("error when delete event in Core Data")
                    abort()
                }
            } else {
                print(error)
            }
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let dateSort = NSSortDescriptor(key: "dateSort", ascending: true)
        
        fetchRequest.sortDescriptors = [dateSort]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "date", cacheName: "event")
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
    
    func saveCoreData(data: Dictionary<String, String>) {
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: managedObjectContext!)
        let event = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext) as! Event
        let host = getHost(data["host"]!)
        let cat = getCategory(data["category"]!)
        event.title = data["title"]
        event.date = data["date"]
        event.from = data["from"]
        event.to = data["to"]
        event.location = data["location"]
        event.desc = data["description"]
        event.capacity = Int(data["capacity"]!)
        event.host = host
        event.category = cat
        
        
        //add to server
        let eventP = PFObject(className:"Events")
        eventP["title"] = data["title"]
        eventP["date"] = data["date"]
        eventP["from"] = data["from"]
        eventP["to"] = data["to"]
        let hostPtr = PFObject(withoutDataWithClassName: "Hosts", objectId: host.id)
        eventP["host"] = hostPtr
        let catPtr = PFObject(withoutDataWithClassName: "Categories", objectId: cat.id)
        eventP["cat"] = catPtr
        eventP["location"] = data["location"]
        eventP["desc"] = data["description"]
        eventP["capacity"] = Int(data["capacity"]!)
        eventP.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("object has been saved")
                event.eventID = eventP.objectId
            } else {
                print("error")
            }
        }

        
        // add event to host and category
        
        //host
        host.addEvent(event)
        //cat
        cat.addEvent(event)
        
        do {
            try self.managedObjectContext!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }

    }
    
    func updateCoreData(data: Dictionary<String, String>) {
        
    }
    
    private func getHost(name: String) -> Host {
        
        let fetchRequest = NSFetchRequest(entityName:"Host")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        var fetchedResults:[Host]? = nil
        
        do {
            fetchedResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [Host]
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return fetchedResults![0]
    }
    
    private func getCategory(name: String) -> Category {
        
        let fetchRequest = NSFetchRequest(entityName:"Category")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        var fetchedResults:[Category]? = nil
        
        do {
            fetchedResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return fetchedResults![0]
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AddEvent") {
            let view = segue.destinationViewController as! AddNewEventViewController
            view.delegate = self
            view.managedObjectContext = managedObjectContext
            
        } else if segue.identifier == "popoverSegue" {
            let logInView = segue.destinationViewController as! LogInViewController
            logInView.eventView = self
            logInView.modalPresentationStyle = UIModalPresentationStyle.Popover
            logInView.popoverPresentationController!.delegate = self
            
        } else if (segue.identifier == "EventDetail") {
            let view = segue.destinationViewController as! EventDetailViewController
            let index = self.tableView.indexPathForSelectedRow!
            if (searchPredicate == nil) {
            view.event = self.fetchedResultsController.objectAtIndexPath(index) as? Event
            } else {
            view.event = filteredData?[index.row]
            }
            view.delegate = self
            //searchController.active = false
        }
        // Set up the back button
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // Search functions
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText != nil {
            searchPredicate = NSPredicate(format: "title contains[c] %@", searchText!)
            filteredData = fetchedResultsController.fetchedObjects!.filter() {
                return self.searchPredicate.evaluateWithObject($0)
                } as? [Event]
            self.tableView.reloadData()
        }
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(searchController)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchPredicate = nil
        filteredData = nil
        activeSearch = false
        self.tableView.reloadData()
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        activeSearch = true
    }
}
