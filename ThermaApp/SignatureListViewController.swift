//
//  SignatureListViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/22/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit

class SignatureListViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newSignatureButton: UIButton!
    
    var agenda: Agenda!
    var isCurrentAgenda: Bool!
    var completion: ((Int) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agenda.attendees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attendeeCell")
        cell!.textLabel!.text = agenda.attendees[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toNewSignature", sender: indexPath.row)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewSignature" {
            let destination = segue.destination as! NewSignatureViewController
            destination.agenda = agenda
            destination.isCurrentAgenda = isCurrentAgenda
            
            if let row = sender as? Int {
                destination.name = agenda.attendees[row]
                destination.signature = agenda.signatures[row]
            }
            
            destination.completion = {
                self.tableView.reloadData()
                self.completion(self.agenda.attendees.count)
            }
        }
    }
}
