//
//  EventDetailViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/5/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import EventKit

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var addCalendarButton: UIButton!
    @IBOutlet weak var RSVPButton: UIButton!
    
    var event:Event? = nil
    var delegate: StoreCoreDataProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Event Detail"

        // Do any additional setup after loading the view.
        titleLabel.text = event!.title
        dateLabel.text = event?.date
        fromLabel.text = event?.from
        toLabel.text = event?.to
        locationLabel.text = event?.location
        hostLabel.text = event?.host!.name
        catLabel.text = event?.category!.name
        descriptionLabel.text = event?.desc
        capacityLabel.text = String(event!.capacity!)
        RSVPButton.hidden = true
        
        // Change the "Add to Calendar" button
        addCalendarButton.backgroundColor = UIColor.clearColor()
        addCalendarButton.layer.cornerRadius = 5
        addCalendarButton.layer.borderWidth = 1
        addCalendarButton.layer.borderColor = UIColor.blueColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            if (Config.didLogIn && !Config.isAdmin && !Config.isRSVPed((self.event?.eventID)!)) {
                self.RSVPButton.hidden = false
            } else {
                self.RSVPButton.hidden = true
            }
        }
    }
    
    
    @IBAction func addRSVP() {
        Config.addEventToRSVPList(eventID: (event?.eventID)!)
    }
    
    @IBAction func saveEvent(sender: AnyObject) {
        
        let eventStore : EKEventStore = EKEventStore()
        
        eventStore.requestAccessToEntityType(.Event, completion: {
            (granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let eventCal:EKEvent = EKEvent(eventStore: eventStore)
                // configure date
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "MM-dd-yyyy HH:mm a"
                let beganDate = self.event!.date! + " " + self.event!.from!
                
                let endDate = self.event!.date! + " " + self.event!.to!
                print(beganDate)
                print(endDate)
                
                eventCal.title = (self.event?.title)!
                eventCal.startDate = dateFormat.dateFromString(beganDate)!
                eventCal.endDate = dateFormat.dateFromString(endDate)!
                eventCal.notes = self.event!.desc
                eventCal.calendar = eventStore.defaultCalendarForNewEvents
                eventCal.location = self.event!.location
                
                do {
                    try eventStore.saveEvent(eventCal, span: .ThisEvent)
                } catch let error as NSError {
                    _ = error
                } catch {
                    fatalError()
                }
                
                print("Saved Event")
            }
        })
    }
}
