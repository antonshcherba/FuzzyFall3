//
//  SettingsViewController.swift
//  Motions
//
//  Created by Admin on 07/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var activityUnits: TimeUnits!
    
    var activeTextField: UITextField!
    
    var settingsManager = SettingsManager()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var activityDurationTextField: UITextField!
    @IBOutlet weak var activityUnitsSegment: UISegmentedControl!
    
    @IBOutlet weak var userAlertEnabledSwitch: UISwitch!
    @IBOutlet weak var userAlertSoundSwitch: UISwitch!
    @IBOutlet weak var userAlertVibrationSwitch: UISwitch!
    
    @IBOutlet weak var emergencyPhone: UITextField!
    @IBOutlet weak var emergencyEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        initializeCloseKeyboardTap()
        
        let detectorSettings = settingsManager.detectorSettings
        activityDurationTextField.text = String(detectorSettings.activityDuration)
        
        if let units = TimeUnits(string: detectorSettings.activityUnits!) {
            activityUnits = units
            activityUnitsSegment.selectedSegmentIndex = units.rawValue
        }
        
        userAlertEnabledSwitch.isOn = detectorSettings.userAlertEnabled
        userAlertSoundSwitch.isOn = detectorSettings.userAlertSound
        userAlertVibrationSwitch.isOn = detectorSettings.userAlertVibration
        
        emergencyPhone.text = detectorSettings.emergencyPhone
        emergencyEmail.text = detectorSettings.emergencyEmail
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        let detectorSettings = settingsManager.detectorSettings
        
        if let units = TimeUnits(rawValue: activityUnitsSegment.selectedSegmentIndex) {
            
            if let duration = Int(activityDurationTextField.text!), duration.isValid(units) {
                detectorSettings.activityDuration = Int64(duration)
                detectorSettings.activityUnits = units.stringValue()
            }
        }
        
        detectorSettings.userAlertEnabled = userAlertEnabledSwitch.isOn
        detectorSettings.userAlertSound = userAlertSoundSwitch.isOn
        detectorSettings.userAlertVibration = userAlertVibrationSwitch.isOn
        
        if let phone = emergencyPhone.text, phone.isValidPhone() {
            detectorSettings.emergencyPhone = phone
        }
        
        if let email = emergencyEmail.text, email.isValidEmail() {
            detectorSettings.emergencyEmail = email
        }
        
        settingsManager.saveDetectorSettings()
        
    }
    
    @IBAction func unitsChanged(_ sender: UISegmentedControl) {
        let units = TimeUnits(rawValue: sender.selectedSegmentIndex)!
        var duration = Duration(activityDurationTextField.text!)!
        activityDurationTextField.text = String(duration)
        
        switch units {
        case .minutes:
            duration = duration.toMinutes(activityUnits)
        case .seconds:
            duration = duration.toSeconds(activityUnits)
        }
        
        activityDurationTextField.text = String(duration)
        activityUnits = units
    }
    @IBAction func switchChanged(_ sender: UISwitch) {
        if !sender.isOn && UserAlertType(rawValue: sender.tag) == nil {
            userAlertSoundSwitch.isOn = sender.isOn
            userAlertVibrationSwitch.isOn = sender.isOn
        }
    }
    
    func initializeCloseKeyboardTap() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleOnTapAnywhereButKeyboard:")
        tapRecognizer.delegate = self //delegate event notifications to this class
        self.view.addGestureRecognizer(tapRecognizer)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let field = activeTextField, !field.text!.isEmpty {
            self.view.endEditing(true)
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        return
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
            
        case activityDurationTextField:
            let units = TimeUnits(rawValue: activityUnitsSegment.tag)
            if let duration = Int(activityDurationTextField.text!), !duration.isValid(units!) {
                let alertViewController = UIAlertController(title: "Duration",
                    message: "Incorrect duration.\n Please enter number between 1 and 5 minutes!",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alertViewController, animated: true, completion: nil)
            }
            
        case emergencyPhone:
            if !emergencyPhone.text!.isValidPhone() {
                let alertViewController = UIAlertController(title: "Phone",
                    message: "Incorrect phone number.\n Please try another!",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alertViewController, animated: true, completion: nil)
            }
            
        case emergencyEmail:
            if !emergencyEmail.text!.isValidEmail() {
                let alertViewController = UIAlertController(title: "E-mail",
                    message: "Incorrect email.\n Please try another!",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alertViewController, animated: true, completion: nil)
            }
        default:
            break
        }
        activeTextField = nil
        return
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text!.isEmpty {
            return false
        }
        textField.resignFirstResponder()
        return true
    }
}
