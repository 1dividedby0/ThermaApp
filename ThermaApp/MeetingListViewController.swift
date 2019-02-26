//
//  MeetingListViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/17/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
import PDFKit

class MeetingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var currentAgendaButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var pastAgendas: [Agenda] = []
    var currentAgenda: Agenda!
    var fileLocalURLs: [String:URL] = [:]
    var downloadURLs: [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        downloadAgendas()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "PENDING"
        } else if section == 1 {
            return "PAST AGENDAS"
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pastAgendas.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgendaCell")
        let nameLabel = cell!.viewWithTag(1) as! UILabel
        let dateLabel = cell!.viewWithTag(2) as! UILabel
        
        if indexPath.section == 0 {
            nameLabel.text = pastAgendas[indexPath.row].name
            dateLabel.text = pastAgendas[indexPath.row].date
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var shouldDoWebView = false
        var agenda: Agenda?
        
        if indexPath.section == 0 {
            agenda = pastAgendas[indexPath.row]
            if pastAgendas[indexPath.row].text.contains("•\n") {
                shouldDoWebView = true
            }
        }
        
        if shouldDoWebView {
            performSegue(withIdentifier: "toWebview", sender: agenda)
        } else {
            performSegue(withIdentifier: "toAgenda", sender: agenda)
        }
        
    }
    
    @IBAction func currentAgenda(_ sender: Any) {
        if currentAgenda.text.contains("•\n") {
            performSegue(withIdentifier: "toWebview", sender: currentAgenda)
        } else {
            performSegue(withIdentifier: "toAgenda", sender: currentAgenda)
        }
    }
    
    func downloadAgendas() {
        
        do {
            // download the current agenda
            let html = try String(contentsOf: URL(string: "https://safety.therma.com/category/weekly-toolbox-meetings/")!)
            let document = try SwiftSoup.parse(html)
            let datesElements = try document.select("h2.entry-title")
            let linksElements = try document.select("p.download-link")
            
            downloadCurrentAgenda(withDatesArray: datesElements, withLinksArray: linksElements)
            
            downloadPastAgendas(withDatesArray: datesElements, withLinksArray: linksElements)
        } catch {}
    }
    
    func downloadCurrentAgenda(withDatesArray datesElements: Elements, withLinksArray linksElements: Elements) {
        let closestIndex = getClosestAgenda(withDatesArray: datesElements, withLinksArray: linksElements)
        
        let downloadLink = getDownloadLink(fromLinkElement: linksElements.get(closestIndex))
        print(downloadLink)
        downloadFromLink(downloadLink, withDestinationName: "CurrentAgenda.pdf", completion: { (agenda) in
            let decoded = UserDefaults.standard.object(forKey: agenda.name)
            do {
                if decoded == nil{
                    self.currentAgenda = agenda
                    let encoded = try NSKeyedArchiver.archivedData(withRootObject: agenda, requiringSecureCoding: false)
                    UserDefaults.standard.set(encoded, forKey: agenda.name)
                } else {
                    let decodedAgenda = NSKeyedUnarchiver.unarchiveObject(with: decoded as! Data) as! Agenda
                    self.currentAgenda = decodedAgenda
                }
            } catch {}
            
        }) { (error) in
            print(error)
        }
    }
    
    func downloadPastAgendas(withDatesArray datesElements: Elements, withLinksArray linksElements: Elements) {
        for i in 0..<linksElements.size() {
            let downloadLink = getDownloadLink(fromLinkElement: linksElements.get(i))
            print(downloadLink)
            downloadFromLink(downloadLink, withDestinationName: "\(i).pdf", completion: { (agenda) in
                // we want to make sure no future agendas or the current agenda is in pastAgendas
                let calendar = Calendar.current
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                
                let components = agenda.date.replacingOccurrences(of: "Week of ", with: "").split(separator: "-")
                let date1 = formatter.date(from: "20\(components[2])/\(components[0])/\(components[1]) 00:00")
                
                let currentDate = Date()
                let date2 = calendar.startOfDay(for: currentDate)
                
                let difference = calendar.dateComponents([Calendar.Component.day], from: date1!, to: date2).day!
                
                if difference > 7 {
                    let decoded = UserDefaults.standard.object(forKey: agenda.name)
                    do {
                        if decoded == nil{
                            self.pastAgendas.append(agenda)
                            let encoded = try NSKeyedArchiver.archivedData(withRootObject: agenda, requiringSecureCoding: false)
                            UserDefaults.standard.set(encoded, forKey: agenda.name)
                        } else {
                            let decodedAgenda = NSKeyedUnarchiver.unarchiveObject(with: decoded as! Data) as! Agenda
                            self.pastAgendas.append(decodedAgenda)
                        }
                    } catch {}
                }
                
                // sort pastAgendas if we are finished loading everything
                if i == linksElements.size() - 1 {
                    self.pastAgendas.sort { (agenda1, agenda2) -> Bool in
                        let components1 = agenda1.date.replacingOccurrences(of: "Week of ", with: "").split(separator: "-")
                        let date1 = formatter.date(from: "20\(components1[2])/\(components1[0])/\(components1[1]) 00:00")
                        
                        let components2 = agenda2.date.replacingOccurrences(of: "Week of ", with: "").split(separator: "-")
                        let date2 = formatter.date(from: "20\(components2[2])/\(components2[0])/\(components2[1]) 00:00")
                        
                        let difference = calendar.dateComponents([Calendar.Component.day], from: date2!, to: date1!).day!
                        return difference > 0
                    }
                }
                self.tableView.reloadData()
            }) { (error) in
                print(error)
            }
        }
        
    }
    
    func getDownloadLink(fromLinkElement element: Element) -> String{
        do{
            let link = try element.select("a").first()!.attr("href")
            let htmlDownloadPage = try String(contentsOf: URL(string: link)!)
            let documentDownloadPage = try SwiftSoup.parse(htmlDownloadPage)
            let downloadLink = try documentDownloadPage.select("div.entry-content").first()!.select("script").first()!.data().split(separator: "\'")[1]
            return String(downloadLink)
        }
        catch {}
        return ""
    }
    
    func getClosestAgenda(withDatesArray datesElements: Elements, withLinksArray linksElements: Elements) -> Int{
        do{
            var dates = [String]()
            
            let calendar = Calendar.current
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let date1 = calendar.startOfDay(for: currentDate)
            var timeDifferences = [Int]()
            for i in 0 ..< datesElements.size() {
                dates.append(String(try datesElements.get(i).text().split(separator: " ")[0]))
                let components = dates[i].split(separator: "-")
                let date2 = formatter.date(from: "20\(components[2])/\(components[0])/\(components[1]) 00:00")
                timeDifferences.append(calendar.dateComponents([Calendar.Component.day], from: date2!, to: date1).day!)
            }
            
            var leastIndex = 0
            var leastElement = timeDifferences[0]
            for i in 0..<timeDifferences.count {
                if leastElement < 0{
                    leastElement = timeDifferences[i]
                    leastIndex = i
                }
                if timeDifferences[i] < leastElement && timeDifferences[i] >= 0 {
                    leastElement = timeDifferences[i]
                    leastIndex = i
                }
            }
            
            return leastIndex
        }
        catch{}
        return -1
    }
    
    func downloadFromLink(_ downloadLink: String, withDestinationName destinationName: String, completion: @escaping (Agenda) -> Void, failure: @escaping (String) -> Void) {
        // code from https://github.com/Alamofire/Alamofire/issues/2319
        
        let directoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderPath: URL = directoryURL.appendingPathComponent("Agendas", isDirectory: true)
        let fileURL: URL = folderPath.appendingPathComponent(destinationName)
        
        fileLocalURLs[destinationName] = fileURL
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(downloadLink, to: destination).response { (response) in
            if let error = response.error {
                failure("Failed to download with response \(error.localizedDescription)")
            }
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                print("Download Link: \(downloadLink)")
                print("Destination: \(destinationName)")
                let pdf = PDFDocument(url: self.fileLocalURLs[destinationName]!)!.string!
                let lines = pdf.components(separatedBy: CharacterSet.newlines)
                
                var date = ""
                var name = ""
                
                for i in 0..<lines.count {
                    if lines[i].contains("Week") {
                        date = lines[i].trimmingCharacters(in: .whitespaces)
                    }
                    if lines[i] == lines[i].uppercased() {
                        name = lines[i].trimmingCharacters(in: .whitespaces)
                        break
                    }
                }
                let text = String(self.formatNormalPDF(pdf, withTitle: name))
                print(text)
                
                let agenda = Agenda(name: name, date: date, text: text)
                
                self.downloadURLs[name] = downloadLink
                
                completion(agenda)
            }
        }
    }
    
    func formatNormalPDF(_ pdf: String, withTitle title: String) -> String{
        var text = pdf.components(separatedBy: "SAFETY REMINDER")[0].components(separatedBy: "Company Name Therma Job Name Date")[1]
        text = text.replacingOccurrences(of: title, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        text = text.replacingOccurrences(of: " ", with: "\n  •")
        text = text.replacingOccurrences(of: "", with: "  •")
        text = text.replacingOccurrences(of: "", with: "  •")
        let lines = text.components(separatedBy: CharacterSet.newlines)
        
        for line in lines {
            // if the first character of a line is lowercased, that probably means the pdf has been parsed badly and that line needs to be concatenated with the previous line
            let firstChar = line.unicodeScalars.first!
            if line.count > 0 && (CharacterSet.lowercaseLetters.contains(firstChar) || CharacterSet.decimalDigits.contains(firstChar)) {
                text = text.replacingOccurrences(of: "\n" + line, with: " " + line)
            }
        }
        return text
    }
    
    func formatWeirdPDF(_ pdf: String, withTitle title: String) -> String{
        var text = pdf.components(separatedBy: "SAFETY REMINDER")[0].components(separatedBy: "Company Name Therma Job Name Date")[1]
        text = text.replacingOccurrences(of: title, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let lines = text.components(separatedBy: CharacterSet.newlines)
        
        for line in lines {
            // if the first character of a line is lowercased, that probably means the pdf has been parsed badly and that line needs to be concatenated with the previous line
            let firstChar = line.unicodeScalars.first!
            if line.count > 0 && (CharacterSet.lowercaseLetters.contains(firstChar) || CharacterSet.decimalDigits.contains(firstChar)) {
                text = text.replacingOccurrences(of: "\n" + line, with: " " + line)
            }
        }
        
        print(text)
        
        text = text.replacingOccurrences(of: "\n\n", with: "\n")
        while text.contains("\n\n") {
            text = text.replacingOccurrences(of: "\n\n", with: "\n")
        }
        text = text.replacingOccurrences(of: " ", with: "")
        text = text.replacingOccurrences(of: "", with: "")
        text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        text = text.replacingOccurrences(of: "\n", with: "\n• ")
        
        if CharacterSet.uppercaseLetters.contains(text.unicodeScalars.first!) || CharacterSet.decimalDigits.contains(text.unicodeScalars.first!) {
            text = "• " + text
        }
        print(text)
        return text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAgenda"{
            let destination = segue.destination as! AgendaViewController
            destination.agenda = sender as! Agenda
            destination.webURL = downloadURLs[destination.agenda.name]
        } else if segue.identifier == "toWebview" {
            let destination = segue.destination as! WebViewController
            
            destination.agenda = sender as! Agenda
            destination.onlineURL = downloadURLs[destination.agenda.name]
        }
    }
}
