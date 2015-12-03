//
//  AddNewHostViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/8/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import CoreData
import Parse

class AddNewHostViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var addEventView: AddNewEventViewController? = nil
    var fromEventForm = false

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        emailTextField.delegate = self
        
        navigationItem.title = "Add New Host"
        
        if (!fromEventForm) {
            cancelButton.hidden = true
        }
        
        // Cancel button
        cancelButton.backgroundColor = UIColor.clearColor()
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Save Button
        saveButton.backgroundColor = UIColor.clearColor()
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        infoTextView.layer.cornerRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addNew(sender: AnyObject) {
        if (nameTextField.text == "") {
            alertLabel.text = "You have to fill in the name"
        } else if (emailTextField.text == "") {
            alertLabel.text = "You have to fill in the email"
        } else {
            let data: Dictionary<String, String> = ["name": nameTextField.text!, "email": emailTextField.text!, "info": infoTextView.text!]
            
            // save to Core Data
            saveToCoreData(data)
            
            if (fromEventForm) {
                addEventView?.hostTextField.text = nameTextField.text
                addEventView?.refreshHostsList()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }

    private func saveToCoreData(data: Dictionary<String, String>) {
        let entity = NSEntityDescription.entityForName("Host", inManagedObjectContext: managedObjectContext!)
        let host = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext) as! Host
        host.name = data["name"]
        host.email = data["email"]
        host.info = data["info"]
        
        do {
            try self.managedObjectContext!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        //add to server
        let hostP = PFObject(className:"Hosts")
        hostP["name"] = data["name"]
        hostP["email"] = data["email"]
        hostP["info"] = data["info"]
        
        hostP.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("object host has been saved")
                host.id = hostP.objectId
            } else {
                print("error")
            }
        }
    }
    
    // dismiss the keyboard when touching anywhere
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // dismiss the keyboard when touching the return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
