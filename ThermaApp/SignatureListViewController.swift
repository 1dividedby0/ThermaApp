//
//  SignatureListViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/22/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit

class SignatureListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newSignatureButton: UIButton!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var agenda: Agenda!
    var isCurrentAgenda: Bool!
    var completion: ((Int) -> Void)!
    
    var displayedAttendees: [String]!
    var displayedSignatures: [UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Attendees"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text == nil
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContent(withSearchText searchText: String) {
        displayedSignatures = []
        displayedAttendees = []
        
        for index in 0..<agenda.attendees.count {
            if agenda.attendees[index].lowercased().contains(searchText.lowercased()) {
                displayedAttendees.append(agenda.attendees[index])
                displayedSignatures.append(agenda.signatures[index])
            }
        }
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return displayedAttendees.count
        }
        
        return agenda.attendees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attendeeCell")
        var attendee = agenda.attendees[indexPath.row]
        if isFiltering() {
            attendee = displayedAttendees[indexPath.row]
        }
        cell!.textLabel!.text = attendee
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toNewSignature", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var index = indexPath.row
            if isFiltering(){
                displayedAttendees.remove(at: index)
                displayedSignatures.remove(at: index)
                index = agenda.attendees.firstIndex(of: displayedAttendees[indexPath.row])!
            }
            agenda.signatures.remove(at: index)
            agenda.attendees.remove(at: index)
            
            if isCurrentAgenda {
                let encoded = NSKeyedArchiver.archivedData(withRootObject: agenda)
                UserDefaults.standard.set(encoded, forKey: "CurrentAgenda")
            }
            
            completion(agenda.attendees.count)
            tableView.reloadData()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewSignature" {
            let destination = segue.destination as! NewSignatureViewController
            destination.agenda = agenda
            destination.isCurrentAgenda = isCurrentAgenda
            
            if let row = sender as? Int {
                var attendee = agenda.attendees[row]
                var signature = agenda.signatures[row]
                if isFiltering() {
                    attendee = displayedAttendees[row]
                    signature = displayedSignatures[row]
                }
                
                destination.index = row
                destination.name = attendee
                destination.signature = signature
            }
            
            destination.completion = {
                self.tableView.reloadData()
                self.completion(self.agenda.attendees.count)
            }
        }
    }
}

extension SignatureListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(withSearchText: searchController.searchBar.text!)
    }
}
