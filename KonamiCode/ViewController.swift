//
//  ViewController.swift
//  KonamiCode
//
//  Created by Sebastien Morel on 10/17/14.
//  Copyright (c) 2014 Plopix. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let recognizer = PlopixKonamiGesture(target: self, action: "launchEasterEgg:")
        view.addGestureRecognizer(recognizer)
        
    }

    
    func launchEasterEgg(recognizer: UITapGestureRecognizer) {
        if ( recognizer.state == .Ended ) {
            println("tapped button")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

