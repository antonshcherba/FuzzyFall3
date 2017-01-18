//
//  Duration+Validators.swift
//  FuzzyFall
//
//  Created by Admin on 02/03/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation

typealias Duration = Int

let durationMax = 300

let durationMin = 0

let durationRange = durationMin...durationMax

extension Duration {
    static let secPerMin = 60
    
    func isValid(_ units:TimeUnits) -> Bool {
        var duration: Duration
        
        switch units {
        case .seconds:
            duration = self
        case .minutes:
            duration = self * Duration.secPerMin
        }
        
        return durationRange ~= duration ? true : false
    }
    
    func toMinutes(_ units: TimeUnits) -> Duration {
        var minutes: Duration
        switch units {
        case .seconds:
            minutes = self / Duration.secPerMin
        case .minutes:
            minutes =  self
        }
        
        if minutes * Duration.secPerMin > durationMax {
            minutes = durationMax / Duration.secPerMin
        }
        
        return minutes
    }
    
    func toSeconds(_ units: TimeUnits) -> Duration {
        var seconds: Duration
        switch units {
        case .seconds:
            seconds = self
        case .minutes:
            seconds =  self * Duration.secPerMin
        }
        
        if seconds > durationMax {
            seconds = durationMax
        }
        return seconds
    }
}
