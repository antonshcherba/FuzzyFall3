//
//  FallDetector.swift
//  Motions
//
//  Created by Admin on 30/11/15.
//  Copyright © 2015 antonShcherba. All rights reserved.
//

import Foundation
import CoreData

class FallDetector: NSObject {
    
    var detectorTimer: Timer = Timer()
    
    let fuzzySolver = FuzzySolver()
    
    var context: NSManagedObjectContext!
    
    let motionManager = MotionManager.sharedInstance
    
    let activityMonitor = ActivityMonitor.sharedInstance
    
    var detectedTime = 0.0
    
    var currentIndex = 0
    
    var firtsLoop = true
    
    let window = 20
    
    fileprivate let detectorQueue = DispatchQueue(
        label: "com.antonShcherba.Fall.detectQueue", attributes: [])
    
    static let sharedInstance = FallDetector()
    
    override init() {
        
        super.init()
    }
    
    func startDetecting() {
        
        let frequency = MotionManager.sharedInstance.motionFrequency
        if firtsLoop {
            detectorTimer = Timer.scheduledTimer(timeInterval: frequency * Double(window) * 2.0,
                target: self, selector: #selector(FallDetector.startDetecting), userInfo: nil, repeats: false)
        } else {
            detectorTimer = Timer.scheduledTimer(timeInterval: frequency,
                target: self, selector: #selector(FallDetector.detectFalls), userInfo: nil, repeats: true)
        }
        firtsLoop = !firtsLoop
    }
    
    func stopDetecting() {
       
        detectorTimer.invalidate()
    }
    
    func detectFalls() {
        
        if motionManager.measures.count < window * 2 {
            return
        }
        
        if activityMonitor.isActive {
            return
        }
        
        detectorQueue.async {
            let currentIndex = self.currentIndex
            let measure = self.motionManager.measures[currentIndex]
            
            self.motionManager.measures.remove(at: currentIndex)
            if round(measure.time) == self.detectedTime {
                return
            }
            
            if self.activityMonitor.isActive {
                return
            }
            
            let userFell = self.fuzzySolver.solve(measure)
            if userFell {
                
                self.stopDetecting()
                print("fall detected with fuzzy logic")
                self.detectedTime = round(measure.time)
                NotificationCenter.default.addObserver(self,
                    selector: #selector(FallDetector.activityDetected(_:)), name: NSNotification.Name(rawValue: kNotification.userActive), object: nil)
                NotificationCenter.default.addObserver(self,
                    selector: #selector(FallDetector.activityDetected(_:)), name: NSNotification.Name(rawValue: kNotification.userNotActive), object: nil)

                self.activityMonitor.startMonitoring(fromIndex: self.currentIndex)
            }
        }
    }
    
    func activityDetected(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        
        switch notification.name {
            
        case Notification.Name(kNotification.userActive):
            print("Fall not deteceted after active")
            startDetecting()
            
        case Notification.Name(kNotification.userNotActive):
            print("Fall deteceted after active")
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: kNotification.fallDetected), object: nil)
            stopDetecting()
            
        default:
            break
        }
        
        self.currentIndex = self.motionManager.measures.count-window
        return
    }
    
    func falseFallDetected(_ notification: Notification) {
        startDetecting()
    }
}
