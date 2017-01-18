//
//  SignUpViewController.swift
//  Motions
//
//  Created by Admin on 08/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    /// the text field which is editing currently
    var activeField: UITextField?
    
    var settingsManager = SettingsManager()
    
    var alertViewController: UIAlertController?
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self

        initializeCloseKeyboardTap()
        // TODO: Add Remember me functionality
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        registerForNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        unregisterForNotifications()
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        
        navigationController?.popViewController(animated: true)
    }
    @IBAction func signUpButtonTapped(_ sender: AnyObject) {
        let object = DatabaseManager.sharedInstance.fetchFirst(User.entityName, query: "%K like %@",
            args: ["username", usernameTextField.text!])
        if object != nil {
            alertViewController = UIAlertController(title: "Error", message: "Such user exists.", preferredStyle: UIAlertControllerStyle.alert)
            alertViewController!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertViewController!, animated: true, completion: nil)
            return
        }
        
        if let username = usernameTextField.text, !username.isValidUsername() {
            alertViewController = UIAlertController(title: "Incorrect login",
                message: "Incorrect login format.\n Please try another!",
                preferredStyle: UIAlertControllerStyle.alert)
            
            alertViewController!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertViewController!, animated: true, completion: nil)
            return
        }
        
        // Creates user
        
        let database = DatabaseManager.sharedInstance
        let user = database.createUser(usernameTextField.text!,
            password: passwordTextField.text!)
        user.detectorSettings = database.createDetectorSettings()
        user.userSettings = database.createUserSettings(firstNameTextField.text!, last: lastNameTextField.text!)
        settingsManager.user = user
        settingsManager.setDefaultDetectorSettings()
        let userDefaults = UserDefaults.standard
        userDefaults.set(user.username, forKey: "loggedUserName")
        
        settingsManager.saveSettings()
        performSegue(withIdentifier: "RevealViewController", sender: self)
    }
    
    /**
     Registers for notifications
     */
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /**
     Unregisters from notifications
     */
    func unregisterForNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func initializeCloseKeyboardTap() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleOnTapAnywhereButKeyboard:")
        tapRecognizer.delegate = self //delegate event notifications to this class
        self.view.addGestureRecognizer(tapRecognizer)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    /**
     Called when text field starts editing
     
     :param: textField edited text field
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    /**
     Called when text field ends editing
     
     :param: textField edited text field
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    /**
     Called when keyboard will show
     
     :param: notification notification
     */
    func keyboardWillShow(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            if let kbSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {
                let insets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
                scrollView.contentInset = insets
                scrollView.scrollIndicatorInsets = insets
                
                var aRect = view.frame
                aRect.size.height -= kbSize.height
                var fieldPoint = activeField!.frame.origin
                fieldPoint.y += navigationController!.navigationBar.frame.size.height

                if !aRect.contains(fieldPoint) {
                    scrollView .scrollRectToVisible(activeField!.frame, animated: true)
                }
            }
        }
    }
    
    /**
     Called when keyboard will hide
     
     :param: notification notification
     */
    func keyboardWillHide(_ notification: Notification) {
        let insets = UIEdgeInsets.zero
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        updateViewConstraints()
    }
    
    /**
     Checks enter button processing
     
     :param: textField edited text field
     :returs: true, if should process enter button
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
