//
//  ViewController.swift
//  KonamiCode
//
//  Created by Sebastien Morel on 10/17/14.
//  Copyright (c) 2014 Plopix. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var stateLabel : UILabel!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let recognizer = PlopixKonamiGesture(target: self, action: #selector(ViewController.launchEasterEgg(_:)))
        view.addGestureRecognizer(recognizer)        
    }
    
    func launchEasterEgg(recognizer: UIGestureRecognizer) {
        if ( recognizer.state == .Ended ) {
            stateLabel.text = "Yeah you did it!"
        }
        if ( recognizer.state == .Failed || recognizer.state == .Cancelled ) {
            stateLabel.text = "Try again!"
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

