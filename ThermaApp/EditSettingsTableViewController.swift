//
//  EditSettingsTableViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 3/15/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit

class EditSettingsTableViewController: UITableViewController {

    @IBOutlet weak var textField: UITextField!
    
    var key: String!
    var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = label.text!
    }
    @IBAction func done(_ sender: Any) {
        UserDefaults.standard.setValue(textField.text!, forKey: key)
        label.text = textField.text!
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
