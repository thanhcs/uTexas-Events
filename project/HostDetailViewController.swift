//
//  HostDetailViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/8/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit

class HostDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    var host:Host? = nil
    var delegate:StoreCoreDataProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Host Information"

        nameLabel.text = host?.name
        infoLabel.text = host?.info
        
        // Change the "events" button
        eventsButton.backgroundColor = UIColor.clearColor()
        eventsButton.layer.cornerRadius = 5
        eventsButton.layer.borderWidth = 1
        eventsButton.layer.borderColor = UIColor.blueColor().CGColor
        // Change the "email" button
        emailButton.backgroundColor = UIColor.clearColor()
        emailButton.layer.cornerRadius = 5
        emailButton.layer.borderWidth = 1
        emailButton.layer.borderColor = UIColor.blueColor().CGColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "EventsOfHost") {
            let view = segue.destinationViewController as! EventsOfHostTableViewController
            view.host = host
        }
        // Set up the back button
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func emailAction(sender: AnyObject) {
        let url = NSURL(string: (host?.email)!)
        UIApplication.sharedApplication().openURL(url!)
    }
}
