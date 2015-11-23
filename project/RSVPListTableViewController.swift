//
//  RSVPListTableViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/22/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import CoreData

class RSVPListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate  {

    var managedObjectContext: NSManagedObjectContext? = nil
    var events:[Event]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName:"Event")
        fetchRequest.predicate = NSPredicate(format: "eventID IN %@", Config.RSVPList!)
        do {
            events = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let event = events![indexPath.row]
        cell.textLabel!.text = event.title
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Destructive, title: "unRSVP") { (action, indexPath) in
            // Delete the row from the data source
            let event = self.events![indexPath.row]
            let id = event.eventID!
            Config.delEventToRSVPList(eventID: id)
            self.events?.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        return [delete]
    }
    
    // Override to support editing the table view.
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        
//        if editingStyle == .Delete {
//            // Delete the row from the data source
//            let event = events![indexPath.row]
//            let id = event.eventID!
//            Config.delEventToRSVPList(eventID: id)
//            events?.removeAtIndex(indexPath.row)
//            
//            
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        }
//    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RSVPToEvent" {
            let view = segue.destinationViewController as! EventDetailViewController
            let index = self.tableView.indexPathForSelectedRow!.row
            view.event = events![index]
        }
        // Set up the back button
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }

}
