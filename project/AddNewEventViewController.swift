//
//  AddNewEventViewController.swift
//  FinalProject
//
//  Created by Thanh Nguyen on 10/22/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import CoreData

class AddNewEventViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    @IBOutlet weak var hostPicker: UIPickerView!
    @IBOutlet weak var catPicker: UIPickerView!
    
    var date: String = ""
    var to: String = ""
    var from: String = ""
    var hosts:[Host]? = nil
    var cats: [Category]? = nil
    
    var delegate:StoreCoreDataProtocol? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hostPicker.tag = 1
        catPicker.tag = 2
        hostTextField.tag = 1
        catTextField.tag = 2
        
        self.navigationItem.title = "Add New Event"

        // Do any additional setup after loading the view.
        self.titleTextField.delegate = self
        myDatePicker.datePickerMode = UIDatePickerMode.Date
        fromTimePicker.datePickerMode = UIDatePickerMode.Time
        toTimePicker.datePickerMode = UIDatePickerMode.Time
        locationTextField.delegate = self
        hostTextField.delegate = self
        descriptionTextField.delegate = self
        capacityTextField.delegate = self
        catTextField.delegate = self
        
        hostPicker.hidden = true
        catPicker.hidden = true
        
        // create hosts array
        let fetchRequest1 = NSFetchRequest(entityName:"Host")
        do {
            hosts = try managedObjectContext!.executeFetchRequest(fetchRequest1) as? [Host]
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        // create categories array
        let fetchRequest2 = NSFetchRequest(entityName:"Category")
        do {
            cats = try managedObjectContext!.executeFetchRequest(fetchRequest2) as? [Category]
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    // DatePicker for date
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
    
    // Picker for Host and Category
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return hosts!.count
        } else {
            return cats!.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return hosts![row].name
        } else {
            return cats![row].name
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            hostTextField.text = hosts![row].name
            hostPicker.hidden = true
        } else if pickerView.tag == 2 {
            catTextField.text = cats![row].name
            catPicker.hidden = true
        }
    }
    
    // Control the keyboard and picker appearance
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField.tag == 1) {
            hostPicker.hidden = false
            catPicker.hidden = true
            view.endEditing(true)
            return false
        } else if (textField.tag == 2) {
            catPicker.hidden = false
            hostPicker.hidden = true
            view.endEditing(true)
            return false
        } else {
            catPicker.hidden = true
            hostPicker.hidden = true
            return true
        }
    }
}
