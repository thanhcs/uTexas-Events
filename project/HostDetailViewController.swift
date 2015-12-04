//
//  HostDetailViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/8/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import MessageUI

class HostDetailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    var host:Host? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Host Information"

        nameLabel.text = host?.name
        infoLabel.text = host?.info
        infoLabel.textColor = UIColor.whiteColor()
        
        // Change the "events" button
        eventsButton.backgroundColor = UIColor.clearColor()
        eventsButton.layer.cornerRadius = 5
        eventsButton.layer.borderWidth = 1
        eventsButton.layer.borderColor = UIColor.whiteColor().CGColor
        // Change the "email" button
        emailButton.backgroundColor = UIColor.clearColor()
        emailButton.layer.cornerRadius = 5
        emailButton.layer.borderWidth = 1
        emailButton.layer.borderColor = UIColor.whiteColor().CGColor

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
        
        if (MFMailComposeViewController.canSendMail()) {
            let emailTitle = "information regarding:" + (host?.name)!
            let messageBody = "Hi, I had a question regarding..."
            let toRecipents = ["\(host!.email)"]
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(messageBody, isHTML: false)
            mc.setToRecipients(toRecipents)
            self.presentViewController(mc, animated: true, completion: nil)
        }else {
            print("No email account found")
        }
    }
    
    // Email Delegate
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
        case MFMailComposeResultSent.rawValue:
            print("Mail sent")
        case MFMailComposeResultFailed.rawValue:
            print("Mail sent failure: \(error?.localizedDescription)")
        default:
            break
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }}
