//
//  EditAgendaViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/19/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit

class EditAgendaViewController: UITableViewController {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var textField: UITextField!
    
    var text: String!
    var attribute: String!
    var completion: ((String) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedText = text {
            textField.text = savedText
        }
        if let attribute = attribute {
            navigationBar.title = attribute
        }
    }
    @IBAction func done(_ sender: Any) {
        completion(textField.text!)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
