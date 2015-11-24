//
//  AddNewCategoryViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/8/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import CoreData

class AddNewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var managedObjectContext:NSManagedObjectContext? = nil
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
    
    @IBAction func addNew(sender: AnyObject) {
        if (nameTextField.text == "") {
            alertLabel.text = "You have to fill in the name"
        } else {
            let data: Dictionary<String, String> = ["name": nameTextField.text!]
            saveToCoreData(data)
            navigationController?.popViewControllerAnimated(false)
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
