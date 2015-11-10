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
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var eventsButton: UIButton!
    
    var host:Host? = nil
    var delegate:StoreCoreDataProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Host Information"

        nameLabel.text = host?.name
        emailLabel.text = host?.email
        infoLabel.text = host?.info
        
        // Change the "Add to Calendar" button
        eventsButton.backgroundColor = UIColor.clearColor()
        eventsButton.layer.cornerRadius = 5
        eventsButton.layer.borderWidth = 1
        eventsButton.layer.borderColor = UIColor.blueColor().CGColor
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
    }
}
