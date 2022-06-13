//
//  LocationDisplayVC.swift
//  UserLocationProfile
//
//  Created by Joeun Kim on 6/11/22.
//

import UIKit
import CoreLocation

class LocationDisplayVC: UIViewController, ST_LocationManagerDelegate {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var stateNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    
    let locationManager = ST_LocationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch locationManager.checkAuthorizationStatus() {
        case .notDetermined:
            print("notDetermined")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(identifier: "LocationServiceAuthorizationVC")
            present(destinationVC, animated: true, completion: nil)
        case .systemNotAllowed:
            print("location service disabled")
            var alert = UIAlertController(title: "Location Service Disabled", message: "Location service is disabled. Please go to Settings, enabled the location service to allow the app access to your current location.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        case .appNotAllowed:
            var alert = UIAlertController(title: "App Not Authorized", message: "We are not authorized to access your location information. Please go to App Settings, enabled the location service of the app to give access to your current location.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let openSettings = UIAlertAction(title: "Open Settings", style: .default, handler: {(action ) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(cancel)
            alert.addAction(openSettings)
            self.present(alert, animated: true, completion: nil)
            print("app not allowed to access location info")
        default:
            print("\(locationManager.checkAuthorizationStatus())")
        }
        
        locationManager.delegate = self
        

    }
    
    func locationDidUpdateWith(city: String, state: String, country: String) {
//        if Thread.isMainThread {
//            print("main!")
//        }
        JKLog.log(message: "\(Thread.current)")

        cityNameLabel.text = city
        stateNameLabel.text = state
        countryNameLabel.text = country
    }
}
