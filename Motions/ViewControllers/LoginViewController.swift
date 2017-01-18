//
//  LoginViewController.swift
//  Motions
//
//  Created by Admin on 09/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import UIKit
import CoreLocation

class LoginViewController: UIViewController,UITextFieldDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    var activeField: UITextField?
    
    var alertViewController: UIAlertController?
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        initializeCloseKeyboardTap()
        getCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        registerForNotifications()
    }
    
    var locationManager = CLLocationManager()
    
    func getCurrentLocation() {
        print("gets current location")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .denied:
            print("Denied")
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            print("Authorized")
        case .notDetermined:
            print("Not deter")
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            print("in use")
        default:
            print("")
        }
        
        locationManager.startUpdatingLocation()
        if CLLocationManager.locationServicesEnabled() {
            print("YES")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterFromNotifications()
    }
    
    @IBAction func loginButtonTapped(_ sender: AnyObject) {
        let user = DatabaseManager.sharedInstance.fetchFirst(User.entityName, query: "%K LIKE %@",
            args: ["username", usernameTextField.text!]) as! User?
        
        if user == nil {
            alertViewController = UIAlertController(title: "Error", message: "Such user doesn't exists.", preferredStyle: UIAlertControllerStyle.alert)
            alertViewController!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertViewController!, animated: true, completion: nil)
            return
        } else if user?.password != passwordTextField.text! {
            alertViewController = UIAlertController(title: "Error", message: "Invalid user password", preferredStyle: UIAlertControllerStyle.alert)
            alertViewController!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertViewController!, animated: true, completion: nil)
            return
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(user?.username, forKey: "loggedUserName")
        
        performSegue(withIdentifier: "RevealViewController", sender: self)
    }
    
    /**
     Registers for notifications
     */
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /**
     Unregisters from notifications
     */
    func unregisterFromNotifications() {
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
     
     - parameter textField: edited text field
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    /**
     Called when keyboard will show
     
     - parameter notification: notification
     */
    func keyboardWillShow(_ notification: Notification) {
        scrollView.isScrollEnabled = true
        
        if let userInfo = notification.userInfo {
            if let kbSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                let insets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
                scrollView.contentInset = insets
                scrollView.scrollIndicatorInsets = insets
                
                var aRect = view.frame
                aRect.size.height -= kbSize.height
                if !aRect.contains(activeField!.frame.origin) {
                    scrollView .scrollRectToVisible(activeField!.frame, animated: true)
                }
            }
        }
    }
    
    /**
     Called when keyboard will hide
     
     - parameter: notification notification
     */
    func keyboardWillHide(_ notification: Notification) {
        scrollView.isScrollEnabled = false
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
