//
//  SettingsTableViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 3/15/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var supervisorLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        supervisorLabel.text = UserDefaults.standard.string(forKey: "supervisor")
        emailLabel.text = UserDefaults.standard.string(forKey: "email")
        fontSizeLabel.text = UserDefaults.standard.string(forKey: "fontSize")
        siteLabel.text = UserDefaults.standard.string(forKey: "site")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sender = supervisorLabel
        var key = ""
        if indexPath.section == 0{
            if indexPath.row == 0{
                sender = supervisorLabel
                key = "supervisor"
            } else if indexPath.row == 1{
                sender = emailLabel
                key = "email"
            }
        } else if indexPath.section == 1{
            sender = fontSizeLabel
            key = "fontSize"
        } else if indexPath.section == 2{
            sender = siteLabel
            key = "site"
        }
        performSegue(withIdentifier: "toEditSettings", sender: (sender, key))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! EditSettingsTableViewController
        let senderTuple = sender as! (UILabel, String)
        destination.label = senderTuple.0
        destination.key = senderTuple.1
    }
}
