//
//  SignatureCreatorViewController.swift
//  ThermaApp
//
//  Created by Dhruv Mangtani on 2/22/19.
//  Copyright © 2019 Dhruv. All rights reserved.
//

import UIKit
import TouchDraw

class SignatureCreatorViewController: UIViewController, TouchDrawViewDelegate {

    @IBOutlet weak var drawView: TouchDrawView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var completion: ((UIImage, [Stroke]) -> Void)!
    var signature: UIImage?
    var strokes: [Stroke]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.delegate = self
        drawView.setWidth(5)
        
        if let loadedStrokes = strokes {
            drawView.importStack(loadedStrokes)
        }
        
        let orientation = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(orientation, forKey: "orientation")
    }
    
    @IBAction func done(_ sender: Any) {
        let orientation = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(orientation, forKey: "orientation")
        dismiss(animated: true) {
            let image = self.drawView.exportDrawing()
            let strokes = self.drawView.exportStack()
            self.completion(image, strokes)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        let orientation = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(orientation, forKey: "orientation")
        dismiss(animated: true, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
}
