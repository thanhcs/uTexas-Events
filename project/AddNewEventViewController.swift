//
//  AddNewEventViewController.swift
//  FinalProject
//
//  Created by Thanh Nguyen on 10/22/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import CoreData

class AddNewEventViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var toTimePicker: UIDatePicker!
    @IBOutlet weak var fromTimePicker: UIDatePicker!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var catTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var capacityTextField: UITextField!
    @IBOutlet weak var alertEmpty: UILabel!
    
    var date: String = ""
    var to: String = ""
    var from: String = ""
    
    var delegate:StoreCoreDataProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Event"

        // Do any additional setup after loading the view.
        self.titleTextField.delegate = self
        myDatePicker.datePickerMode = UIDatePickerMode.Date
        fromTimePicker.datePickerMode = UIDatePickerMode.Time
        toTimePicker.datePickerMode = UIDatePickerMode.Time
        locationTextField.delegate = self
        hostTextField.delegate = self
        descriptionTextField.delegate = self
        capacityTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveEvent(sender: AnyObject) {
        // need to check nil
        if (titleTextField.text == "" || locationTextField.text == "" || hostTextField.text == "" || descriptionTextField.text == "" || capacityTextField.text == "" || catTextField.text == "" || date == "" || from == "" || to == "") {
            alertEmpty.text = "You have to fill in all information!"
        } else {
            let data: Dictionary<String, String> = ["title": titleTextField.text!, "date": date, "from": from, "to": to, "location": locationTextField.text!, "host": hostTextField.text!, "category": catTextField.text!, "description": descriptionTextField.text!, "capacity": capacityTextField.text!]
            self.delegate?.saveCoreData(data)
            print(data["from"])
            navigationController?.popViewControllerAnimated(false)
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
    
    @IBAction func datePickerAction(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        date = dateFormatter.stringFromDate(myDatePicker.date)
        print(date)
    }
    
    @IBAction func fromPickerAction(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        from = dateFormatter.stringFromDate(fromTimePicker.date)
        print(from)
    }
    @IBAction func toPickerAction(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        to = dateFormatter.stringFromDate(toTimePicker.date)
    }

}
