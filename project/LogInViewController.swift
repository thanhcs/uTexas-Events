//
//  LogInViewController.swift
//  project
//
//  Created by Thanh Nguyen on 11/22/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameStack: UIStackView!
    @IBOutlet weak var lastNameStack: UIStackView!
    @IBOutlet weak var emailStack: UIStackView!
    @IBOutlet weak var registerForgotStack: UIStackView!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var logInViewButton:UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 300, height: 210)
        firstNameStack.hidden = true
        lastNameStack.hidden = true
        emailStack.hidden = true
        registerButton.hidden = true
        responseLabel.text = ""
        logInViewButton.hidden = true
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        responseLabel.text = ""
    }
    
    @IBAction func login(sender: AnyObject) {
        self.preferredContentSize = CGSize(width: 300, height: 210)
        firstNameStack.hidden = true
        lastNameStack.hidden = true
        emailStack.hidden = true
        registerButton.hidden = true
        registerForgotStack.hidden = false
        responseLabel.text = ""
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        
        if (usernameTextField.text == "") {
            responseLabel.text = "Please fill in the username"
            
        } else if (passwordTextField.text == "") {
            responseLabel.text = "Please fill in the password"
            
        } else {
            PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    Config.didLogIn = true
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    let errorString = error!.userInfo["error"] as? NSString
                    self.responseLabel.text = errorString as? String
                }
            }
        }
    }
    
    @IBAction func register(sender: AnyObject) {
        self.preferredContentSize = CGSize(width: 300, height: 300)
        firstNameStack.hidden = false
        lastNameStack.hidden = false
        emailStack.hidden = false
        logInButton.hidden = true
        registerButton.hidden = false
        registerForgotStack.hidden = true
        logInViewButton.hidden = false
        responseLabel.text = ""
    }
    
    @IBAction func registerAction(sender: AnyObject) {
        if (firstNameTextField.text == "") {
            responseLabel.text = "Please fill in your first name"
            
        } else if (lastNameTextField.text == "") {
            responseLabel.text = "Please fill in your last name"
            
        } else if (emailTextField.text == "") {
            responseLabel.text = "Please fill in your email"
            
        } else if (usernameTextField.text == "") {
            responseLabel.text = "Please fill in username"
            
        } else if (passwordTextField.text == "") {
            responseLabel.text = "Please fill in password"
            
        } else {
            let user = PFUser()
            user.username = usernameTextField.text!
            user.password = passwordTextField.text!
            user.email = emailTextField.text!
            user["firstName"] = firstNameTextField.text!
            user["lastName"] = lastNameTextField.text!
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo["error"] as? NSString
                    self.responseLabel.text = errorString as? String
                } else {
                    Config.didLogIn = true
                }
            }
        }
    }
}
