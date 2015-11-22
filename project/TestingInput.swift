//
//  TestingInput.swift
//  project
//
//  Created by Thanh Nguyen on 11/5/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TestingInput {
    var managedObjectContext: NSManagedObjectContext? = nil
    
    init(manage: NSManagedObjectContext) {
        // set context
        managedObjectContext = manage
    }
    
    func inputToCoreData() {
        // add host
        let host = NSEntityDescription.insertNewObjectForEntityForName("Host", inManagedObjectContext: managedObjectContext!) as! Host
        host.name = "MutualMobile"
        host.info = ""
        host.email = "thanhnguyencs@utexas.edu"
        
        // add host
        let host1 = NSEntityDescription.insertNewObjectForEntityForName("Host", inManagedObjectContext: managedObjectContext!) as! Host
        host1.name = "Visa"
        host1.info = ""
        host1.email = "thanhnguyencs@utexas.edu"
        
        // add category
        // add host
        let cat = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: managedObjectContext!) as! Category
        cat.name = "Android"
        
        do {
            try managedObjectContext!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        // add Event
        let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: managedObjectContext!) as! Event
        event.title = "Sample1"
        event.date = "11/15/2015"
        event.from = "8:30"
        event.to = "10:00"
        event.host = host
        event.category = cat
        event.location = "GDC 1.304"
        event.desc = "abc"
        event.capacity = 20
        
        // add Event
        let event1 = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: managedObjectContext!) as! Event
        event1.title = "Sample2"
        event1.date = "11/16/2015"
        event1.from = "8:30"
        event1.to = "10:00"
        event1.host = host1
        event1.category = cat
        event1.location = "GDC 1.304"
        event1.desc = "abc"
        event1.capacity = 20
        
        // add Event
        let event2 = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: managedObjectContext!) as! Event
        event2.title = "Sample3"
        event2.date = "11/16/2015"
        event2.from = "8:30"
        event2.to = "10:00"
        event2.host = host1
        event2.category = cat
        event2.location = "GDC 1.304"
        event2.desc = "abc"
        event2.capacity = 20
        
        do {
            try managedObjectContext!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func checkCoreData() {
        // check event
        let fetchRequest = NSFetchRequest(entityName:"Event")
    
        var fetchedResults:[Event]? = nil
    
        do {
            fetchedResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        print("Number of events:")
        print(fetchedResults?.count)
    
        // check hosts
        let fetchRequest1 = NSFetchRequest(entityName:"Host")
    
        var fetchedResults1:[Host]? = nil
    
        do {
            fetchedResults1 = try managedObjectContext!.executeFetchRequest(fetchRequest1) as? [Host]
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        print("Number of Host:")
        print(fetchedResults1!.count)
    
        let fetchRequest2 = NSFetchRequest(entityName:"Category")
    
        var fetchedResults2:[Category]? = nil
    
        do {
                fetchedResults2 = try managedObjectContext!.executeFetchRequest(fetchRequest2) as? [Category]
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        print("Number of category:")
        print(fetchedResults2!.count)
    }
}