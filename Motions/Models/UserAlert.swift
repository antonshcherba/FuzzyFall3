//
//  UserAlert.swift
//  Motions
//
//  Created by Admin on 08/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

private let kSystemSoundID_Alarm: UInt32 = 1304

import Foundation
import AVFoundation

class UserAlert : NSObject {
    
    var enabled = true
    
    var soundEnabled = true
    
    var vibrationEnabled = true
    
    var vibrationTimer: Timer = Timer()
    
    var endVibrationTimer: Timer = Timer()
    
    var soundTimer: Timer = Timer()
    
    var endSoundTimer: Timer = Timer()
    
    var duration = 10
    
    var vibrationStep = 2
    
    var alertViewController: UIAlertController?
    
    func configure() {
        let settings = SettingsManager().detectorSettings
        
        enabled = settings.userAlertEnabled
        soundEnabled = settings.userAlertSound
        vibrationEnabled = settings.userAlertVibration
    }
    
    func fallAlert() {
        configure()
        
        if !enabled {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotification.trueFall), object: nil)
        }
        
        let alertDate = Date()
        alertViewController = UIAlertController(title: "Fall Detected", message: "Fall detected \(alertDate)", preferredStyle: UIAlertControllerStyle.alert)
        alertViewController!.addAction(UIAlertAction(title: "Dismis", style: .cancel, handler: { (action) -> Void in
            self.stopTimers()
            
            NotificationCenter.default.post(name: Notification.Name(kNotification.falseFall), object: nil)
        }))
        
        if vibrationEnabled {
            endVibrationTimer = Timer.scheduledTimer(timeInterval: Double(duration),
                target: self, selector: #selector(UserAlert.stopAlert), userInfo: nil, repeats: false)
            vibrationTimer = Timer.scheduledTimer(timeInterval: Double(vibrationStep),
                target: self, selector: #selector(UserAlert.vibrate), userInfo: nil, repeats: true)
        }
        
        if soundEnabled {
            endSoundTimer = Timer.scheduledTimer(timeInterval: Double(duration),
                target: self, selector: #selector(UserAlert.stopAlert), userInfo: nil, repeats: false)
            soundTimer = Timer.scheduledTimer(timeInterval: Double(vibrationStep),
                target: self, selector: #selector(UserAlert.playSound), userInfo: nil, repeats: true)
        }
        
        let windows = UIApplication.shared.windows
//        let active = windows.filter( {($0.rootViewController?.isBeingPresented())!})
//        active.first?.rootViewController?.presentViewController(alertViewController!, animated: true, completion: nil)
        let active = windows.filter {$0.rootViewController is UINavigationController}
        active.first?.rootViewController?.present(alertViewController!, animated: true, completion: nil)
    }
    
    func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func  playSound() {
        AudioServicesPlaySystemSound(kSystemSoundID_Alarm)
    }
    
    func stopTimers() {
        endVibrationTimer.invalidate()
        endSoundTimer.invalidate()
        vibrationTimer.invalidate()
        soundTimer.invalidate()
    }
    
    func stopAlert() {
        stopTimers()
        if let alert = alertViewController {
            alert.dismiss(animated: true, completion: nil)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotification.trueFall), object: nil)
    }
}
