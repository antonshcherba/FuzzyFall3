//
//  MainModel.swift
//  Motions
//
//  Created by Admin on 08/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation
import CoreLocation
import skpsmtpmessage

class MainModel: NSObject, CLLocationManagerDelegate {
    
    /// represents MainModel singleton
    static let sharedInstance = MainModel()
    
    /// represents motion device manager
    let motionManager = MotionManager.sharedInstance//MotionManager()
        
    let databaseManager = DatabaseManager.sharedInstance
        
    let fallDetector = FallDetector.sharedInstance
    
    let userAlert = UserAlert()
    
    var locationManager: LocationManager?
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainModel.locationFound(_:)), name: NSNotification.Name(rawValue: kNotification.foundLocation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainModel.fallDetected(_:)), name: NSNotification.Name(rawValue: kNotification.fallDetected), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainModel.falseFallDetected(_:)), name: NSNotification.Name(rawValue: kNotification.falseFall), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainModel.trueFallDetected(_:)), name: NSNotification.Name(rawValue: kNotification.trueFall), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func deviceMotionAvailable() -> Bool {
        return motionManager.isDeviceMotionAvailable
    }
    
    func fallDetectorActive() -> Bool {
        return motionManager.isDeviceMotionActive
    }
    
    func startDetecting() {
        motionManager.startDeviceUpdates()
        fallDetector.startDetecting()
    }
    
    func stopDetecting() {
        motionManager.stopDeviceMotionUpdates()
        fallDetector.stopDetecting()
    }
    
    func fallDetected(_ notification: Notification) {
        userAlert.fallAlert()
    }
    
    func falseFallDetected(_ notification: Notification) {
        startDetecting()
    }
    
    func trueFallDetected(_ notification: Notification) {
        if locationManager == nil {
            locationManager = LocationManager()
        }
        
        stopDetecting()
        locationManager?.findCurrentLocation()
    }
    
    func locationFound(_ notification: Notification) {
        locationManager = nil
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        if let location = userInfo["location"] as? CLLocation {
        }
        
        if let locationString = userInfo["locationString"] as? String {
            let emergency = Emergency()
            let settings = SettingsManager().userSettings
            
            let message = "\(settings.firstName!) \(settings.lastName!) " +
                "is in the dangerous situation.\n" + locationString + "Sent via FuzzyFall"
            emergency.notifyWith(message)
        }
    }
}
