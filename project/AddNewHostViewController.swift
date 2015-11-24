//
//  AddNewHostViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/8/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit

class AddNewHostViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var alertLabel: UILabel!
    
    var delegate: StoreCoreDataProtocol? = nil
    var fromEventForm = false

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        emailTextField.delegate = self
        navigationItem.title = "Add New Host"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNew(sender: AnyObject) {
        if (nameTextField.text == "") {
            alertLabel.text = "You have to fill in the name"
        } else if (emailTextField.text == "") {
            alertLabel.text = "You have to fill in the email"
        } else {
            let data: Dictionary<String, String> = ["name": nameTextField.text!, "email": emailTextField.text!, "info": infoTextView.text!]
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
