//
//  AddNewCategoryViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/8/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import CoreData
import Parse

class AddNewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var managedObjectContext:NSManagedObjectContext? = nil
    var addEventView: AddNewEventViewController? = nil
    var fromEventForm = false

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        
        if (!fromEventForm) {
            cancelButton.hidden = true
        }
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
        } else {
            let data: Dictionary<String, String> = ["name": nameTextField.text!]
            
            // Save to Core Data
            saveToCoreData(data)
            
            if (fromEventForm) {
                addEventView?.catTextField.text = nameTextField.text
                addEventView?.refreshCatsList()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func saveToCoreData(data: Dictionary<String, String>) {
        let entity = NSEntityDescription.entityForName("Category", inManagedObjectContext: managedObjectContext!)
        let cat = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext) as! Category
        cat.name = data["name"]
        
        do {
            try self.managedObjectContext!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        //add to server
        let catP = PFObject(className:"Categories")
        catP["name"] = data["name"]
        
        catP.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("object host has been saved")
                cat.id = catP.objectId
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
