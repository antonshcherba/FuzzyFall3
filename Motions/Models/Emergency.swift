//
//  Emergency.swift
//  FuzzyFall
//
//  Created by Admin on 10/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation
import skpsmtpmessage

class Emergency {
    
    var sends = false
    
    func notifyWith(_ body:String) {
        if sends {
            return
        }
        sends = true
        
        let message = SKPSMTPMessage()
        message.fromEmail = kApplication.email
        var phone = SettingsManager.sharedInstance.detectorSettings.emergencyPhone!
        let email = SettingsManager.sharedInstance.detectorSettings.emergencyEmail!
        phone.remove(at: phone.startIndex)
        
        message.toEmail = phone + gatewayForPhone(phone)!
        message.bccEmail = email
        message.relayHost = kApplication.host
        message.requiresAuth = true
        message.login = kApplication.email
        message.pass = kApplication.password
        message.wantsSecure = true
        
        message.subject = "Dangerous situation"
        let parts = [kSKPSMTPPartContentTypeKey:"text/plain",
            kSKPSMTPPartMessageKey:body,
            kSKPSMTPPartContentTransferEncodingKey:"8bit"]
        message.parts = [parts]
        
//        message.send()
        print(body)
        sends = false
    }
    
    fileprivate func gatewayForPhone(_ phone:String) -> String? {
        var gateway = ""
        var code = phone.substring(to: phone.characters.index(phone.endIndex, offsetBy: -7))
        
        switch code.characters.count {
        case 3:
            code = "38" + code
        case 4:
            code = "3" + code
        case 6:
            code.remove(at: code.startIndex)
            
        default:
            break
        }
        
        switch code {
        case "38067", "38068", "38096", "38097", "38098":
            gateway = "@sms.kyivstar.net"
        case "3050", "3066", "3095", "3099":
            gateway = "@sms.umc.ua"
        default:
            return nil
        }
        
        return gateway
    }
}
