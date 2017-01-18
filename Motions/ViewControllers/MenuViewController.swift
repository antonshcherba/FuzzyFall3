//
//  MenuViewController.swift
//  Motions
//
//  Created by Admin on 07/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    @IBOutlet weak var userLabel: UILabel!
    
    override func viewDidLoad() {
        let settings = SettingsManager().userSettings
        userLabel.text = "\(settings.firstName!) \(settings.lastName!)"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            MainModel.sharedInstance.stopDetecting()
            revealViewController().navigationController?.popToRootViewController(animated: true)
        }
    }
}
