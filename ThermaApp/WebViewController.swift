//
//  WebViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/19/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    
    var agenda: Agenda!
    var onlineURL: String!
    var isCurrentAgenda: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()  
        navigationItem.title = agenda.date
        webView.load(URLRequest(url: URL(string: onlineURL)!))
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toSubmit" {
            let destination = segue.destination as! SubmitAgendaTableViewController
            destination.agenda = agenda
            destination.webURL = onlineURL
            destination.isCurrentAgenda = isCurrentAgenda
        }
    }
}
