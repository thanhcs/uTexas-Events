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
    
    var host:Host? = nil
    var delegate:StoreCoreDataProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = host?.name
        emailLabel.text = host?.email
        infoLabel.text = host?.info
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
