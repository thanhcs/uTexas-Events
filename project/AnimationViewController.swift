//
//  AnimationViewController.swift
//  project
//
//  Created by Justin Baiko on 11/30/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import CoreData
import Parse

class AnimationViewController: UIViewController, HolderViewDelegate {

    var holderView = HolderView(frame: CGRectZero)
    var managedObjectContext: NSManagedObjectContext? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        // Keep log in old account
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            Config.didLogIn = true
            if (!(currentUser!["isAdmin"] as! Bool)) {
                let triggerTime = (Int64(NSEC_PER_SEC) * 2)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { () -> Void in
                    do {
                        try currentUser?.fetch()
                    } catch _ {
                        print ("can't refrest user's data")
                        self.logout()
                    }
                    Config.RSVPList = currentUser!["eventRSVPs"] as? [String]
                    print(Config.RSVPList)
                })
            }
        }
        
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
        
        // pulling data
        let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let group:dispatch_group_t = dispatch_group_create()
        
        dispatch_group_async(group, queue, {
            self.addHosts()
            print("host")
        });
        
        dispatch_group_async(group, queue, {
            self.addCats()
            print("cat")
        });
        
        dispatch_group_notify(group, queue, {
            self.addEvents()
            print("event")
        })

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addHolderView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func logout() {
        PFUser.logOut()
        Config.RSVPList = nil
        Config.isAdmin = false
        Config.didLogIn = false
    }
    
    func addHosts() {
        let query = PFQuery(className: "Hosts")
        do {
            if let objects = try query.findObjects() as [PFObject]? {
                print("Number of host objects:" + String(objects.count))
                for object in objects {
                    print((object.objectForKey("name") as? String)!)
                    let host = NSEntityDescription.insertNewObjectForEntityForName("Host", inManagedObjectContext: self.managedObjectContext!) as! Host
                    host.name = (object.objectForKey("name") as? String)!
                    host.email = (object.objectForKey("email") as? String)!
                    host.info = (object.objectForKey("info") as? String)!
                    host.id = object.objectId
                }
            }
        } catch _ {
            print("Error when pulling host' data")
            abort()
        }
        
        print("Successfully pulling hosts' data")
    }
    
    func addCats() {
        let query = PFQuery(className: "Categories")
        do {
            if let objects = try query.findObjects() as [PFObject]? {
                print("Number of cat objects:" + String(objects.count))
                for object in objects {
                    print((object.objectForKey("name") as? String)!)
                    let cat = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: self.managedObjectContext!) as! Category
                    cat.name = (object.objectForKey("name") as? String)!
                    cat.id = object.objectId
                }
            }
            
        } catch _ {
            print("Error when pulling cats' data")
            abort()
        }
        print("Successfully pulling hosts' data")
    }
    
    func addEvents() {
        let query = PFQuery(className: "Events")
        query.findObjectsInBackgroundWithBlock {
            
            (objects:[PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // success
                if let objects = objects! as [PFObject]? {
                    print("Number of event objects:" + String(objects.count))
                    for object in objects {
                        print((object.objectForKey("title") as? String)!)
                        let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: self.managedObjectContext!) as! Event
                        //print(event.objectForKey("host")!)
                        event.title = (object.objectForKey("title") as? String)!
                        event.date = (object.objectForKey("date") as? String)!
                        event.from = (object.objectForKey("from") as? String)!
                        event.to = (object.objectForKey("to") as? String)!
                        event.location = (object.objectForKey("location") as? String)!
                        event.desc = (object.objectForKey("desc") as? String)!
                        event.capacity = (object.objectForKey("capacity") as? Int)!
                        event.eventID = object.objectId
                        
                        let host = self.getHostById(object.objectForKey("host")!.objectId!!)
                        host.addEvent(event)
                        event.host = host
                        
                        let cat = self.getCategoryById(object.objectForKey("cat")!.objectId!!)
                        cat.addEvent(event)
                        event.category = cat
                    }
                }
                
                //                do {
                //                    try self.managedObjectContext!.save()
                //                } catch {
                //                    fatalError("Failure to save context: \(error)")
                //                }
                
            } else {
                print("Error when pulling events' data")
                print("Error: \(error!) \(error!.userInfo)")
                abort()
            }
        }
        print("Successfully pulling events' data")
    }
    
    private func getHostById(id: String) -> Host {
        
        let fetchRequest = NSFetchRequest(entityName:"Host")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
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
    
    private func getCategoryById(id: String) -> Category {
        
        let fetchRequest = NSFetchRequest(entityName:"Category")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
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
        
    func addHolderView() {
        let boxSize: CGFloat = 100.0
        holderView.frame = CGRect(x: view.bounds.width / 2 - boxSize / 2,
            y: view.bounds.height / 2 - boxSize / 2,
            width: boxSize,
            height: boxSize)
        holderView.parentFrame = view.frame
        holderView.delegate = self
        view.addSubview(holderView)
        holderView.addOval()
    }
    
    func animateLabel() {
        // 1
        holderView.removeFromSuperview()
        view.backgroundColor = UIColor.orangeColor()
        
        // 2
        let label: UILabel = UILabel(frame: view.frame)
        label.textColor = Colors.white
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 50.0)
        label.textAlignment = NSTextAlignment.Center
        label.text = "uTexas Events"
        label.transform = CGAffineTransformScale(label.transform, 0.25, 0.25)
        view.addSubview(label)
        
        // 3
        UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: ({
                label.transform = CGAffineTransformScale(label.transform, 4.0, 4.0)
            }), completion: { finished in
                //self.addButton()
                self.performSegueWithIdentifier("appSegue", sender: self)
        })
    }
    
    func addButton() {
        let button = UIButton()
        button.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
        button.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        view.addSubview(button)
    }
    
    func buttonPressed(sender: UIButton!) {
        view.backgroundColor = Colors.white
        holderView = HolderView(frame: CGRectZero)
        addHolderView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "appSegue" {
            let appdel = UIApplication.sharedApplication().delegate as! AppDelegate
            let destinationVC = segue.destinationViewController as! UITabBarController
            appdel.goToApp(destinationVC)
            
        }
    }
        
}

