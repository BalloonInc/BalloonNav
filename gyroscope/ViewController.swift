//
//  ViewController.swift
//  gyroscope
//
//  Created by Pieterjan Criel on 26/03/17.
//  Copyright © 2017 Pieterjan Criel. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    let manager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.01
            manager.startAccelerometerUpdates(to: .main) {
                [weak self] (data: CMAccelerometerData?, error: Error?) in
                if let acceleration = data?.acceleration {
                    self?.label1.text = "\(acceleration.x)"
                    self?.label2.text = "\(acceleration.y)"
                    self?.label3.text = "\(acceleration.z)"
                    print("\(acceleration.z)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

