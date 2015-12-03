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
    @IBOutlet weak var usernameStack: UIStackView!
    @IBOutlet weak var passwordStack: UIStackView!
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
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var registerViewButton: UIButton!
    @IBOutlet weak var forgotViewButton: UIButton!
    
    
    var eventView:UIViewController? = nil

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
        responseLabel.textColor = UIColor.redColor()
        resetPasswordButton.hidden = true
        forgotViewButton.layer.cornerRadius = 5
        
        // Buttons
        logInButton.layer.cornerRadius = 5
        registerButton.layer.cornerRadius = 5
        resetPasswordButton.layer.cornerRadius = 5
        logInViewButton.layer.cornerRadius = 5
        registerViewButton.layer.cornerRadius = 5
        
        
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
        logInViewButton.hidden = true
        logInButton.hidden = false
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        
        if (usernameTextField.text == "") {
            responseLabel.text = "Please input the username"
            
        } else if (passwordTextField.text == "") {
            responseLabel.text = "Please input the password"
            
        } else {
            PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    Config.didLogIn = true
                    self.dismissViewControllerAnimated(true, completion: nil)
                    if let user = PFUser.currentUser() {
                        if (user["isAdmin"] as! Bool) {
                            Config.isAdmin = true
                            print("Admin")
                            self.eventView?.navigationItem.leftBarButtonItem?.title = "Log out"
                            self.eventView?.navigationItem.leftBarButtonItem?.enabled = true
                            self.eventView?.navigationItem.rightBarButtonItem?.title = "Add Event"
                            self.eventView?.navigationItem.rightBarButtonItem?.enabled = true
                        } else {
                            print("here")
                            Config.RSVPList = user["eventRSVPs"] as? [String]
                            self.eventView?.navigationItem.leftBarButtonItem!.title = "RSVPs"
                            self.eventView?.navigationItem.leftBarButtonItem?.enabled = true
                            self.eventView?.navigationItem.rightBarButtonItem?.title = "Log out"
                            self.eventView?.navigationItem.rightBarButtonItem?.enabled = true
                        }
                    }
                    
                } else {
                    if (error!.code == 101) {
                        self.responseLabel.text = "Wrong username/password"
                    } else {
                        let errorString = error!.userInfo["error"] as? NSString
                        self.responseLabel.text = errorString as? String
                    }
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
    
    @IBAction func recoveringPassword(sender: AnyObject) {
        self.preferredContentSize = CGSize(width: 300, height: 150)
        firstNameStack.hidden = true
        lastNameStack.hidden = true
        emailStack.hidden = false
        logInButton.hidden = true
        registerButton.hidden = true
        registerForgotStack.hidden = true
        logInViewButton.hidden = true
        registerButton.hidden = true
        responseLabel.text = ""
        resetPasswordButton.hidden = false
        usernameStack.hidden = true
        passwordStack.hidden = true
    }
    
    @IBAction func recoveringPasswordAction (sender: AnyObject) {
        
        if (emailTextField.text == "") {
            responseLabel.text = "Please input your email"
            
        } else {
            PFUser.requestPasswordResetForEmailInBackground(emailTextField.text!)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func registerAction(sender: AnyObject) {
        if (firstNameTextField.text == "") {
            responseLabel.text = "Please input your first name"
            
        } else if (lastNameTextField.text == "") {
            responseLabel.text = "Please input your last name"
            
        } else if (emailTextField.text == "") {
            responseLabel.text = "Please input your email"
            
        } else if (usernameTextField.text == "") {
            responseLabel.text = "Please input username"
            
        } else if (passwordTextField.text == "") {
            responseLabel.text = "Please input password"
            
        } else {
            let user = PFUser()
            user.username = usernameTextField.text!
            user.password = passwordTextField.text!
            user.email = emailTextField.text!
            user["firstName"] = firstNameTextField.text!
            user["lastName"] = lastNameTextField.text!
            user["isAdmin"] = false
            user["eventRSVPs"] = [String]()
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    if (error.code == 203) {
                        self.responseLabel.text = "Email has already used"
                    } else {
                        let errorString = error.userInfo["error"] as? NSString
                        self.responseLabel.text = errorString as? String
                    }
                } else {
                    Config.didLogIn = true
                    self.dismissViewControllerAnimated(true, completion: nil)
                
                    Config.RSVPList = user["eventRSVPs"] as? [String]
                    self.eventView?.navigationItem.leftBarButtonItem!.title = "RSVPs"
                    self.eventView?.navigationItem.leftBarButtonItem?.enabled = true
                    self.eventView?.navigationItem.rightBarButtonItem?.title = "Log out"
                    self.eventView?.navigationItem.rightBarButtonItem?.enabled = true
                }
            }
        }
    }
}
