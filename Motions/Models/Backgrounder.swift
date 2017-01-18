//
//  Backgrounder.swift
//  FuzzyFall
//
//  Created by Admin on 12/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation
import CoreTelephony
import CoreLocation
import AVFoundation

class Backgounder: NSObject {
    
    static let sharedInstance = Backgounder()
    
    fileprivate var callCenter = CTCallCenter()
    
    fileprivate var player: AVAudioPlayer?
    
    fileprivate var locationManager = CLLocationManager()
    
    override init() {
    
        super.init()
        
        callCenter.callEventHandler = block
    }
    
    func start() {
        runAudio()
    }
    
    func stop() {
        stopAudio()
    }
    
    func block (_ call:CTCall!) {
        
        switch call.callState {
            
        case CTCallStateDialing,CTCallStateIncoming:
            let app = UIApplication.shared
            var background_task = UIBackgroundTaskInvalid
            
            background_task = app.beginBackgroundTask {
                self.locationManager.startUpdatingLocation()
                while true {
                    Thread.sleep(forTimeInterval: 1)
                }
                app.endBackgroundTask(background_task)
            }
            
        case CTCallStateDisconnected:
            locationManager.stopUpdatingLocation()
            
        default:
            break
        }
    }
    
    func runAudio() {
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(AVAudioSessionCategoryPlayAndRecord, with: .mixWithOthers)
        } catch let error {
            print("Error occured: \(error)")
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "1min", withExtension: "mp3")!)
        } catch let error {
            print("Error: \(error)")
        }
        
        player?.numberOfLoops = -1
        player?.play()
    }
    
    func stopAudio() {
        player?.stop()
    }
    
    func audioInterrupted(_ notification: Notification) {
        let type = notification.userInfo![AVAudioSessionInterruptionTypeKey] as! AVAudioSessionInterruptionType
        
        switch type {
        case .began:
            player?.stop()
        case .ended:
            player?.play()
        }
    }
}
