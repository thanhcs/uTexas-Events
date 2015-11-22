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

class EventTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, StoreCoreDataProtocol, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var searchController: UISearchController!
    var searchPredicate: NSPredicate!
    var filteredData: [Event]? = nil
    var activeSearch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "uTexas Events"
        definesPresentationContext = true

        NSFetchedResultsController.deleteCacheWithName(nil)
        
        //Deletes core data stored
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        let coord = appDel.persistentStoreCoordinator
        
        var fetchRequest = NSFetchRequest(entityName: "Event")
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
        
        fetchRequest = NSFetchRequest(entityName: "Host")
        deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
        
        fetchRequest = NSFetchRequest(entityName: "Category")
        deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
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
    
        var query = PFQuery(className:"Events")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) Events.")
                // Do something with the found objects
                if let objects = objects! as [PFObject]? {
                    for object in objects {
                        //print(object.objectId!)
                        self.addObject(object)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchPredicate = nil
        filteredData = nil
        self.tableView.reloadData()
    }
    
    
    func addObject(object: PFObject) {
        
        
        let event1 = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: managedObjectContext!) as! Event
        
        let host1 = NSEntityDescription.insertNewObjectForEntityForName("Host", inManagedObjectContext: managedObjectContext!) as! Host
        
        let cat1 = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: managedObjectContext!) as! Category
        
        

        var query = PFQuery(className: "Events")
        query.includeKey("host")
        query.includeKey("cat")
        query.getObjectInBackgroundWithId(object.objectId!, block: {
            (obj, error)in
            if let event = obj! as? PFObject {
                //print(event.objectForKey("host")!)
                event1.title = (event.objectForKey("title") as? String)!
                event1.date = (event.objectForKey("date") as? String)!
                event1.from = (event.objectForKey("from") as? String)!
                event1.to = (event.objectForKey("to") as? String)!
                event1.location = (event.objectForKey("location") as? String)!
                event1.desc = (event.objectForKey("desc") as? String)!
                event1.capacity = (event.objectForKey("capacity") as? Int)!
                
                let pointer = object["host"] as? PFObject
                host1.email = pointer!["email"] as! String
                host1.info = pointer!["info"] as! String
                host1.name = pointer!["name"] as! String

                
                let pointer2 = object["cat"] as? PFObject
                cat1.name = pointer2!["name"] as! String
                
            
                
            } else {
                print(error)
            }
        })
        
        var triggerTime = (Int64(NSEC_PER_SEC) * 1)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.outputStuff(event1,h: host1,c: cat1)
        })
        
    }
    
    func outputStuff(e: Event,h: Host,c: Category) {
        
                e.host = h
                e.category = c
        
                do {
                    try self.managedObjectContext!.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return  event.date
        } else {
            return ""
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let context = self.fetchedResultsController.managedObjectContext
        context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
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
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        let fromSort = NSSortDescriptor(key: "from", ascending: true)
        
        fetchRequest.sortDescriptors = [dateSort, fromSort]
        
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

                var Host1 = PFObject(className:"Hosts")
                Host1["name"] = host.name
                Host1["info"] = host.info
                Host1["email"] = host.email
        
                var Cat1 = PFObject(className:"Categories")
                Cat1["name"] = cat.name
        
                var Event1 = PFObject(className:"Events")
                Event1["title"] = data["title"]
                Event1["date"] = data["date"]
                Event1["from"] = data["from"]
                Event1["to"] = data["to"]
                Event1["host"] = Host1
                Event1["cat"] = Cat1
                Event1["location"] = data["location"]
                Event1["desc"] = data["description"]
                Event1["capacity"] = Int(data["capacity"]!)
                Event1.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("object has been saved")
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
        }
        if (segue.identifier == "EventDetail") {
            let view = segue.destinationViewController as! EventDetailViewController
            let index = self.tableView.indexPathForSelectedRow!
            print(index)
            if (searchPredicate == nil) {
            view.event = self.fetchedResultsController.objectAtIndexPath(index) as? Event
            } else {
            view.event = filteredData?[index.row]
            }
            print("here")
            view.delegate = self
            //searchController.active = false
        }
        // Set up the back button
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
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
