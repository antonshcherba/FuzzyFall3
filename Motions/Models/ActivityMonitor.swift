//
//  File.swift
//  Motions
//
//  Created by Admin on 05/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation
import CoreTelephony
import CoreFoundation

class ActivityMonitor: NSObject {
    
    var monitorTimer: Timer = Timer()
    
    let motionManager = MotionManager.sharedInstance
    
    let callChecker = CallChecker()
    
    var duration = 0
    
    var isActive = false
    
    fileprivate var startIndex = 0
    
    fileprivate var stopIndex = 0
    
    fileprivate var lockObserver: UnsafeRawPointer!
    
    fileprivate let accelThreshold = 0.2
    
    fileprivate let rollThreshold = 0.2
    
    fileprivate let pitchThreshold = 0.2
    
    fileprivate let yawThreshold = 0.2
    
    static let sharedInstance = ActivityMonitor()
    
    fileprivate let activityQueue = DispatchQueue(
        label: "com.antonShcherba.Fall.activityQueue", attributes: [])
    
    override init() {
        
        super.init()
    }
    
    func startMonitoring(fromIndex index:Int) {
        if isActive {
            return
        } else {
            isActive = true
        }
        
        let settings = SettingsManager.sharedInstance.detectorSettings
        duration = Int(settings.activityDuration)
        let units = TimeUnits(string: settings.activityUnits!)
        duration = duration.toSeconds(units!)

        NotificationCenter.default.addObserver(self, selector: #selector(ActivityMonitor.userCalled(_:)), name: NSNotification.Name(rawValue: kNotification.userCalls), object: nil)
        
        callChecker.startChecking()
        startLockMonitoring()
        startMotionMonitoring(index)
    }
    
    func stopMonitoring(_ msg: String=kNotification.userActive) {
        if isActive == false {
            return
        }
        
        isActive = false
        monitorTimer.invalidate()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: msg), object: nil)
        }
        NotificationCenter.default.removeObserver(self)
        CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(), lockObserver)
    }
    
    fileprivate func startMotionMonitoring(_ fromIndex:Int) {
        startIndex = fromIndex+10
        DispatchQueue.main.async {
            self.monitorTimer = Timer.scheduledTimer(timeInterval: Double(self.duration),
                target: self, selector: #selector(ActivityMonitor.stopMotionMonitoring), userInfo: nil, repeats: false)
        }
        
        
    }
    
    func stopMotionMonitoring() {
        
        stopIndex = motionManager.measures.count
        let arr = Array(motionManager.measures[startIndex...stopIndex-1])
        
        self.activityQueue.async { [unowned self] () -> Void in
            let sdAccel = self.standardDeviation(arr.map {
                pow($0.xAccel,2) +
                    pow($0.yAccel,2) +
                    pow($0.zAccel,2)
                })
            let sdRoll = self.standardDeviation(arr.map { $0.roll })
            let sdPitch = self.standardDeviation(arr.map { $0.pitch })
            let sdYaw = self.standardDeviation(arr.map { $0.yaw })
            
            print("accel: \(sdAccel)\nroll: \(sdRoll)\npitch: \(sdPitch)\nsdYaw: \(sdYaw)")
            if sdAccel < self.accelThreshold &&
                sdRoll < self.rollThreshold &&
                sdPitch < self.pitchThreshold &&
                sdYaw < self.yawThreshold {
                    self.stopMonitoring(kNotification.userNotActive)
            } else {
                self.stopMonitoring(kNotification.userActive)
            }
        }
    }
    
    func userCalled(_ notification: Notification) {
        let callState = notification.object as! String
        
        switch callState {
            
        case CTCallStateDialing,
        CTCallStateConnected,
        CTCallStateDisconnected:
            monitorTimer.invalidate()
            stopMonitoring(kNotification.userActive)
            
        default:
            break
        }
    }
    
    func startLockMonitoring() {
        lockObserver = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            lockObserver,
            { (_, lockObserver, name, _, _) -> Void in
                let mySelf = Unmanaged<ActivityMonitor>.fromOpaque(lockObserver!).takeUnretainedValue()
                
                mySelf.stopMonitoring()
            },
            "com.apple.iokit.hid.displayStatus" as CFString!,
            nil,
            .deliverImmediately)
    }
    
    func standardDeviation(_ arr : [Double]) -> Double {
        let length = Double(arr.count)
        let avg = arr.reduce(0, {$0 + $1}) / length
        let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
}
