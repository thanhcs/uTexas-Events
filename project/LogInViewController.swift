//
//  LogInViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/22/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {
    
    @IBOutlet weak var firstNameStack: UIStackView!
    @IBOutlet weak var lastNameStack: UIStackView!
    @IBOutlet weak var emailStack: UIStackView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 300, height: 300)
        firstNameStack.hidden = true
        lastNameStack.hidden = true
        emailStack.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func login(sender: AnyObject) {
        if (usernameTextField.text == "") {
            usernameTextField.textColor = UIColor.redColor()
            usernameTextField.text = "Please fill in"
        } else if (passwordTextField.text == "") {
            passwordTextField.textColor = UIColor.redColor()
            usernameTextField.text = "Please fill in"
        } else {
            PFUser.logInWithUsernameInBackground("myname", password:"mypass") {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    // Do stuff after successful login.
                } else {
                    // The login failed. Check error to see why.
                }
            }
        }
    }
}
