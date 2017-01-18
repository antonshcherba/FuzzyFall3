//
//  SettingsManager.swift
//  Motions
//
//  Created by Admin on 08/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//



import Foundation

enum TimeUnits: Int {
    case seconds=0, minutes
    
    func stringValue() -> String {
        switch self {
        case .seconds:
            return "Seconds"
        case .minutes:
            return "Minutes"
        }
    }
    
    init?(string: String) {
        switch string {
        case "Seconds":
            self = .seconds
        case "Minutes":
            self = .minutes
        default:
            return nil
        }
    }
}

enum UserAlertType: Int {
    case soundAlert=1
    case vibroAlert
    
}

class SettingsManager {
    
    static let sharedInstance = SettingsManager()
    
    var detectorSettings: DetectorSettings {
        return user.detectorSettings!
    }
    
    var userSettings: UserSettings {
        return user.userSettings!
    }
    
    let context = DatabaseManager.sharedInstance.context
    
    var user: User!
    
    init() {
        let userDefaults = UserDefaults.standard
        
        if let username = userDefaults.string(forKey: "loggedUserName") {
            let database = DatabaseManager.sharedInstance
            
            if let user = database.fetchFirst(User.entityName, query: "%K LIKE %@", args: ["username", username]) as? User {
                self.user = user
            }
        }
    }
    
    func setDefaultDetectorSettings() {
        let settings = detectorSettings
        
        settings.activityDuration = 10
        settings.activityUnits = "Seconds"
        settings.userAlertEnabled = true
        settings.userAlertSound = false
        settings.userAlertVibration = true
        settings.emergencyPhone = kApplication.phone
        settings.emergencyEmail = kApplication.email
    }
    
    func saveDetectorSettings() {
        DatabaseManager.sharedInstance.saveSettings(detectorSettings)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "settingsChangedNotification"),
            object: self, userInfo: ["detectorSettings":detectorSettings])
    }
    
    func saveUserSettings() {
        DatabaseManager.sharedInstance.saveSettings(userSettings)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "settingsChangedNotification"),
            object: self, userInfo: ["userSettings":userSettings])
    }
    
    func saveSettings() {
        saveUserSettings()
        saveDetectorSettings()
    }
}
