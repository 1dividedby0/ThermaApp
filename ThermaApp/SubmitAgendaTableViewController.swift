//
//  SubmitAgendaTableViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/19/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit
import PDFKit
import MessageUI

class SubmitAgendaTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var supervisorLabel: UILabel!
    @IBOutlet weak var signaturesLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    var agenda: Agenda!
    var webURL: String!
    var dateExpanded: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if agenda.supervisor == "" {
            supervisorLabel.text = UserDefaults.standard.string(forKey: "supervisor")
        } else {
            supervisorLabel.text = agenda.supervisor
        }
        
        signaturesLabel.text = "\(agenda.signatures.count)"
        
        if agenda.site == "" {
            siteLabel.text = UserDefaults.standard.string(forKey: "site")
        } else {
            siteLabel.text = agenda.site
        }
        
        topicLabel.text = agenda.name
        instructorLabel.text = agenda.instructor
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        dateLabel.text = formatter.string(from: Date())
        var dateComponents = DateComponents()
        let agendaDateComps = agenda.date.components(separatedBy: "-")
        dateComponents.year = Int("20\(agendaDateComps[2])")
        dateComponents.month = Int(agendaDateComps[0])
        dateComponents.day = Int(agendaDateComps[1])
        datePicker.date = Calendar.current.date(from: dateComponents)!
        dateExpanded = true
    }
    
    @IBAction func didChangeValue(_ sender: Any) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        agenda.date = dateFormatter.string(from: datePicker.date)
        dateLabel.text = agenda.date
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = nil
        submitButton.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        tableView.tableFooterView = submitButton
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 && indexPath.section == 1{
            let cell = tableView.viewWithTag(100) as! UITableViewCell
            if !dateExpanded{
                dateExpanded = true
                return 144
            }
            dateExpanded = false
            return 54
        }
        // whatever the normal height is
        return 54
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "editAttribute", sender: ("Supervisor", supervisorLabel))
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "toSignatureList", sender: self)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "editAttribute", sender: ("Site", siteLabel))
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "editAttribute", sender: ("Topic", topicLabel))
            } else if indexPath.row == 2 {
                performSegue(withIdentifier: "editAttribute", sender: ("Instructor", instructorLabel))
            } else if indexPath.row == 3 {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        let document = PDFDocument(url: URL(string: webURL)!)
        let page = document!.page(at: 1)
        let pageBounds = page!.bounds(for: .cropBox)
        for index in 0..<agenda.signatures.count {
            let starting_y = pageBounds.midY+250
            let imageBounds = CGRect(x: Int(pageBounds.midX) - 20, y: Int(starting_y) - (30*index),  width: 250, height: 75)
            let imageStamp = ImageAnnotation(with: agenda.signatures[index], withBounds: imageBounds, withProperties: nil)
            page!.addAnnotation(imageStamp)
        }
        
        sendEmail(data: document!.dataRepresentation()!)
    }
    
    func sendEmail(data: Data) {
        // code from https://stackoverflow.com/questions/30423583/attach-a-pdf-file-to-email-swift
        let mailView = MFMailComposeViewController()
        mailView.mailComposeDelegate = self
        
        mailView.setToRecipients(["dhruv.mangtani@gmail.com"])
        mailView.setSubject("Therma Safety Meeting")
        mailView.setMessageBody("Warning: signatures will not show if viewed on the Gmail iOS app.", isHTML: true)
        
        mailView.addAttachmentData(data, mimeType: "application/pdf", fileName: "\(agenda.name!).pdf")
        
        present(mailView, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error == nil {
            agenda.submitted = true
            let encoded = NSKeyedArchiver.archivedData(withRootObject: agenda)
            UserDefaults.standard.set(encoded, forKey: agenda.name)
        }
        dismiss(animated: true, completion: nil)
        navigationController!.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editAttribute" {
            let senderTuple = (sender as! (String, UILabel))
            let senderType = senderTuple.0
            let label = senderTuple.1
            let senderText = label.text!
            
            let destination = segue.destination as! EditAgendaViewController
            destination.text = senderText
            destination.attribute = senderType
            destination.completion = { text in
                label.text = text
                switch senderType {
                case "Supervisor":
                    self.agenda.supervisor = text
                case "Site":
                    self.agenda.site = text
                case "Topic":
                    self.agenda.name = text
                case "Instructor":
                    self.agenda.instructor = text
                default:
                    print("Error")
                }
                
                let encoded = NSKeyedArchiver.archivedData(withRootObject: self.agenda)
                UserDefaults.standard.set(encoded, forKey: self.agenda.name)
            }
        } else if segue.identifier == "toSignatureList" {
            let destination = segue.destination as! SignatureListViewController
            destination.agenda = agenda
            destination.completion = { numSignatures in
                self.signaturesLabel.text = "\(numSignatures)"
            }
        }
    }
}

// code taken from https://medium.com/@rajejones/add-a-signature-to-pdf-using-pdfkit-with-swift-7f13f7faad3e
class ImageAnnotation: PDFAnnotation {
    var image: UIImage!
    
    init(with image: UIImage!, withBounds bounds: CGRect, withProperties properties: [AnyHashable:Any]?) {
        super.init(bounds: bounds, forType: PDFAnnotationSubtype.stamp, withProperties: properties)
        self.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        guard let cgImage = image.cgImage else {return}
        context.draw(cgImage, in: bounds)
    }
    
}
