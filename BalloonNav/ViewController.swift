//
//  ViewController.swift
//  gyroscope
//
//  Created by Pieterjan Criel on 26/03/17.
//  Copyright © 2017 Pieterjan Criel. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation

class ViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    
    var lastLocation: CLLocation?
    var startRecordingTime = 0.0
    var currentRecordingTime = 0.0
    var recording = false
    
    var locationAccelerationMap: [[Double]] = [] // Maps time on [x_acc,y_acc,z_acc,lat_long]
    
    @IBAction func toggleRecord(_ sender: UIButton) {
        recording = !recording
        if recording {
            locationAccelerationMap = []
            startRecordingTime = NSDate().timeIntervalSince1970
            recordButton.setTitle("Stop recording", for: .normal)
            shareButton.isEnabled = false
        }
        else {
            recordButton.setTitle("Record", for: .normal)
            shareButton.isEnabled = true
        }
    }
    
    @IBAction func share(_ sender: Any) {
        let fileName = "acceleration-location.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Time,x_acc,y_acc,z_acc,latitude,longitude\n"
        
        for dataPoint in locationAccelerationMap {
            let newLine = "\(dataPoint[0]),\(dataPoint[1]),\(dataPoint[2]),\(dataPoint[3]),\(dataPoint[4]),\(dataPoint[5])\n"
            csvText.append(newLine)
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        let activityViewController = UIActivityViewController(activityItems: [path as Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocation()
        initMotion()
    }
    
    fileprivate func initLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    fileprivate func initMotion() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.05
            motionManager.startAccelerometerUpdates(to: .main) {
                [weak self] (data: CMAccelerometerData?, error: Error?) in
                if let strongSelf = self, let acceleration = data?.acceleration {
                    strongSelf.xLabel.text = "\(acceleration.x)"
                    strongSelf.yLabel.text = "\(acceleration.y)"
                    strongSelf.zLabel.text = "\(acceleration.z)"
                    strongSelf.currentRecordingTime = NSDate().timeIntervalSince1970
                    if strongSelf.recording {
                        strongSelf.locationAccelerationMap.append([strongSelf.currentRecordingTime,
                                                                   acceleration.x,
                                                                   acceleration.y,
                                                                   acceleration.z,
                                                                   strongSelf.lastLocation?.coordinate.latitude ?? -9999.9,
                                                                   strongSelf.lastLocation?.coordinate.longitude ?? -9999.9
                            ])
                        strongSelf.timeLabel.text = String(format: "%.2fs", strongSelf.currentRecordingTime-strongSelf.startRecordingTime)
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastLocation = location
            latitudeLabel.text = "\(location.coordinate.latitude)"
            longitudeLabel.text = "\(location.coordinate.longitude)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to record, we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

