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
    
    var event:Event? = nil
    var delegate: StoreCoreDataProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
