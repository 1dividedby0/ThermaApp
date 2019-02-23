//
//  ViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/6/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit
import SwiftSoup
import AWSLambda
import Alamofire
import PDFKit

class AgendaViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var continueButton: UIButton!
    
    var agenda: Agenda!
    var isCurrentAgenda: Bool!
    var webURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.backgroundColor = view.tintColor
        continueButton.layer.cornerRadius = 8
        
        navigationItem.title = agenda.date
        titleLabel.text = agenda.name
        
        textView.text = agenda.text
    }
   
    @IBAction func `continue`(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSubmit" {
            let destination = segue.destination as! SubmitAgendaTableViewController
            destination.agenda = agenda
            destination.webURL = webURL
            destination.isCurrentAgenda = isCurrentAgenda
        }
    }
}

//        let lambdaInvoker = AWSLambdaInvoker.default()
//        lambdaInvoker.invokeFunction("therma", jsonObject: []).continueWith { (task) -> Any? in
//
//            if let pdf = task.result as? String {
//                print(pdf)
//                DispatchQueue.main.async {
//                    let lines = pdf.components(separatedBy: CharacterSet.newlines)
//                    for i in 0...lines.count {
//
//                        if lines[i].contains("Week") {
//                            self.weekLabel.text = lines[i]
//                        }
//                        if lines[i].contains("Date") {
//                            self.titleLabel.text = lines[i+2]
//                            break
//                        }
//                    }
//                    let text = pdf[pdf.range(of: "Date")!.upperBound...]
//                    self.textView.text = String(text)
//                }
//            }
//            return nil
//        }
