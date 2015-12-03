//
//  AddNewEventViewController.swift
//  FinalProject
//
//  Created by Thanh Nguyen on 10/22/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import CoreData
import Parse

extension NSDate {
    
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
    }
}

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
    @IBOutlet weak var saveButton: UIButton!
    
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
        
        dispatch_sync(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            // set up default date and time
            let todaysDate:NSDate = NSDate()
            let dateFormatter:NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            self.date = dateFormatter.stringFromDate(todaysDate)
            dateFormatter.dateFormat = "hh:mm a"
            self.from = dateFormatter.stringFromDate(todaysDate)
            self.to = dateFormatter.stringFromDate(todaysDate)
            
            self.refreshCatsList()
            self.refreshHostsList()
        }
        
        // save button 
        saveButton.backgroundColor = UIColor.clearColor()
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.whiteColor().CGColor
        

        // Do any additional setup after loading the view.
        self.titleTextField.delegate = self
        myDatePicker.datePickerMode = UIDatePickerMode.Date
        myDatePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
        fromTimePicker.datePickerMode = UIDatePickerMode.Time
        fromTimePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
        toTimePicker.datePickerMode = UIDatePickerMode.Time
        toTimePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
        locationTextField.delegate = self
        hostTextField.delegate = self
        descriptionTextField.delegate = self
        capacityTextField.delegate = self
        catTextField.delegate = self
        
        hostPicker.hidden = true
        catPicker.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshHostsList() {
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
        hostPicker.reloadAllComponents()
    }
    
    func refreshCatsList() {
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
        catPicker.reloadAllComponents()
    }
    
    @IBAction func saveEvent(sender: AnyObject) {
        // need to check nil
        if (titleTextField.text == "" || locationTextField.text == "" || hostTextField.text == "" || descriptionTextField.text == "" || capacityTextField.text == "" || catTextField.text == "") {
            alertEmpty.text = "You have to fill in all information!"
        } else if (!verifyDate()) {
            alertEmpty.text = "The input date is invalid"
        } else {
            let data: Dictionary<String, String> = ["title": titleTextField.text!, "date": date, "from": from, "to": to, "location": locationTextField.text!, "host": hostTextField.text!, "category": catTextField.text!, "description": descriptionTextField.text!, "capacity": capacityTextField.text!]
            self.delegate?.saveCoreData(data)
            navigationController?.popViewControllerAnimated(false)
        }
    }
    
    private func verifyDate() -> Bool {
        
        let todaysDate:NSDate = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
        let tempFromDate = dateFormatter.dateFromString(date + " " + from)
        let tempToDate = dateFormatter.dateFromString(date + " " + from)
        if (todaysDate.isGreaterThanDate(tempFromDate!) || tempFromDate!.isGreaterThanDate(tempToDate!)) {
            print("false")
            return false
        }
        print("true")
        return true
    }
    
    // dismiss the keyboard when touching anywhere
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        catPicker.hidden = true
        hostPicker.hidden = true
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
            return hosts!.count + 2
        } else {
            return cats!.count + 2
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // add blank row
        if (row == 0) {
            return ""
        }
        
        if pickerView.tag == 1 {
            if (row == (hosts?.count)! + 1) {
                return "Add new host.."
            }
            return hosts![row - 1].name
        } else {
            if (row == (cats?.count)! + 1) {
                return "Add new category.."
            }
            return cats![row - 1].name
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            if (row == 0) {
                hostTextField.text = ""
                hostPicker.hidden = true
            } else if (row == (hosts?.count)! + 1) {
                self.performSegueWithIdentifier("addHostNewEvent", sender: self)
            } else {
                hostTextField.text = hosts![row - 1].name
                hostPicker.hidden = true
            }
            
        } else if pickerView.tag == 2 {
            if (row == 0) {
                catTextField.text = ""
                catPicker.hidden = true
            } else if (row == (cats?.count)! + 1){
                self.performSegueWithIdentifier("addCatNewEvent", sender: self)
            } else {
                catTextField.text = cats![row - 1].name
                catPicker.hidden = true
            }
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
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.hostPicker.hidden = true
            self.catPicker.hidden = true
        }
        
        if (segue.identifier == "addHostNewEvent") {
            let view = segue.destinationViewController as! AddNewHostViewController
            view.fromEventForm = true
            view.managedObjectContext = managedObjectContext
            view.addEventView = self
        } else if (segue.identifier == "addCatNewEvent") {
            let view = segue.destinationViewController as! AddNewCategoryViewController
            view.fromEventForm = true
            view.managedObjectContext = managedObjectContext
            view.addEventView = self
        }
        // Set up the back button
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
}
