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
    
    var completion: ((UIImage) -> Void)!
    var signature: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.delegate = self
        
        // Do any additional setup after loading the view.
        let orientation = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(orientation, forKey: "orientation")
    }
    
    @IBAction func done(_ sender: Any) {
        let orientation = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(orientation, forKey: "orientation")
        dismiss(animated: true) {
            let image = self.drawView.exportDrawing()
            self.completion(image)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
