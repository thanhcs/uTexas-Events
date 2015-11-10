//
//  AddNewCategoryViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/8/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit

class AddNewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    
    var delegate: StoreCoreDataProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
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
            delegate?.saveCoreData(data)
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
}
