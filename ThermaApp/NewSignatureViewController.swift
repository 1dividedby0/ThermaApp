//
//  NewSignatureViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/22/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit

class NewSignatureViewController: UITableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    var signature: UIImage!
    var name: String?
    
    var agenda: Agenda!
    var isCurrentAgenda: Bool!
    var completion: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if name != nil {
            nameTextField.text = name!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            performSegue(withIdentifier: "toSignatureCreator", sender: self)
        }
    }

    @IBAction func done(_ sender: Any) {
        if signature != nil {
            dismiss(animated: true) {
                self.agenda.attendees.append(self.nameTextField.text!)
                self.agenda.signatures.append(self.signature)
                
                if self.isCurrentAgenda {
                    let encoded = NSKeyedArchiver.archivedData(withRootObject: self.agenda)
                    UserDefaults.standard.set(encoded, forKey: "CurrentAgenda")
                }
                self.completion()
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toSignatureCreator" {
            let destination = segue.destination as! SignatureCreatorViewController
            destination.completion = { image in
                self.signature = image
            }
        }
    }
}
