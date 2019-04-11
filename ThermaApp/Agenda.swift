//
//  Agenda.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/17/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import Foundation
import UIKit
import TouchDraw

class Agenda: NSObject, NSCoding {
    
    var name: String!
    var date: String!
    var text: String!
    var attendees: [String]!
    var signatures: [UIImage]!
    var signaturesStrokes: [[Stroke]]!
    var submitted: Bool!
    
    var supervisor: String!
    var site: String!
    var instructor: String!
    
    init(name: String, date: String, text: String) {
        self.name = name
        self.date = date
        self.text = text
        self.attendees = [String]()
        self.signatures = [UIImage]()
        self.signaturesStrokes = [[Stroke]]()
        self.submitted = false
        self.supervisor = ""
        self.site = ""
        self.instructor = ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(text, forKey: "text")
        aCoder.encode(attendees, forKey: "attendees")
        aCoder.encode(signatures, forKey: "signatures")
        aCoder.encode(signaturesStrokes, forKey: "signaturesStrokes")
        aCoder.encode(submitted, forKey: "submitted")
        
        aCoder.encode(supervisor, forKey: "supervisor")
        aCoder.encode(site, forKey: "site")
        aCoder.encode(instructor, forKey: "instructor")
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String
        date = aDecoder.decodeObject(forKey: "date") as? String
        text = aDecoder.decodeObject(forKey: "text") as? String
        attendees = aDecoder.decodeObject(forKey: "attendees") as? [String]
        signatures = aDecoder.decodeObject(forKey: "signatures") as? [UIImage]
        signaturesStrokes = aDecoder.decodeObject(forKey: "signaturesStrokes") as? [[Stroke]]
        submitted = aDecoder.decodeObject(forKey: "submitted") as? Bool
        
        supervisor = aDecoder.decodeObject(forKey: "supervisor") as? String
        site = aDecoder.decodeObject(forKey: "site") as? String
        instructor = aDecoder.decodeObject(forKey: "instructor") as? String
    }
}
