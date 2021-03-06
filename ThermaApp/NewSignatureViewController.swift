//
//  NewSignatureViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/22/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit
import TouchDraw

class NewSignatureViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var signature: UIImage!
    var strokes: [Stroke]!
    var name: String?
    var index: Int?
    
    var agenda: Agenda!
    var completion: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        if name != nil {
            nameTextField.text = name!
        }
        
        if nameTextField.text!.isEmpty {
            doneButton.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            performSegue(withIdentifier: "toSignatureCreator", sender: self)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = nameTextField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        if newText.isEmpty {
            doneButton.isEnabled = false
        }else{
            doneButton.isEnabled = true
        }
        
        return true
    }

    @IBAction func done(_ sender: Any) {
        let newNameTaken = agenda.attendees.contains(nameTextField.text!) && name == nil
        let editedNameTaken = name != nil && name != nameTextField.text! && agenda.attendees.contains(nameTextField.text!)
        
        if newNameTaken || editedNameTaken {
            // name already exists
            let alert = UIAlertController(title: "Name Taken", message: "This attendee has already been taken", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        if nameTextField.text!.isEmpty && name == nil {
            let alert = UIAlertController(title: "Missing Name", message: "Please add a name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        if signature == nil {
            let alert = UIAlertController(title: "Missing Signature", message: "Please tap signature and sign", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        dismiss(animated: true) {
            // we are adding a signature, not editing one
            if self.name == nil{
                self.agenda.attendees.append(self.nameTextField.text!)
                self.agenda.signatures.append(self.signature)
            } else {
                // editing signature
                self.agenda.attendees[self.index!] = self.nameTextField.text!
                self.agenda.signatures[self.index!] = self.signature
            }
            
            let encoded = NSKeyedArchiver.archivedData(withRootObject: self.agenda)
            UserDefaults.standard.set(encoded, forKey: self.agenda.name)
            
            self.completion()
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
            if index != nil {
                destination.strokes = agenda.signaturesStrokes[index!]
            }
            destination.completion = { image, strokes in
                self.signature = image
                self.strokes = strokes
                if self.index != nil{
                    self.agenda.signaturesStrokes[self.index!] = strokes
                } else {
                    if self.agenda.signaturesStrokes == nil {
                        self.agenda.signaturesStrokes = []
                    }
                    self.agenda.signaturesStrokes.append(strokes)
                }
            }
        }
    }
}
