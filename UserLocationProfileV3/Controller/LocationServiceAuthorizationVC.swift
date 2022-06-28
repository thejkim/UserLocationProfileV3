//
//  ViewController.swift
//  UserLocationProfile
//
//  Created by Joeun Kim on 6/11/22.
//

import UIKit
import CoreLocation

class LocationServiceAuthorizationVC: UIViewController {
//    func locationDidChangePermission(to permission: ST_LocationManager.PermissionRequestResult) {
//        JKLog.log(message: "")
//        let storyboard = 
//        self.dismiss(animated: true, completion: nil)
//    }
    
    
    let locationManager = LocationManager.shared
    
    @IBOutlet weak var informativeMessageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in LocationServiceAuthorizationVC")
        
//        locationManager.delegate = self
        
//        checkAuthorizationStatus()
        
    }
    
    func checkAuthorizationStatus() {
        switch locationManager.checkAuthorizationStatus() {
        case .systemNotAllowed:
            var alertDialog = UIAlertController(title: "Location Services", message: "You disabled location services. We need your current location to provide services. Please go to Setting to allow us access your location.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertDialog.addAction(ok)
            self.present(alertDialog, animated: true)
        case .notDetermined:
            locationManager.requestWhenInUse()
        case .appNotAllowed:
            // display alert dialog to redirect user to app's setting
            var alertDialog = UIAlertController(title: "Location Services", message: "We need your current location to provide services. Please go to the app's setting to allow us access your location.", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let openSetting = UIAlertAction(title: "Open Setting", style: .default, handler: nil)
            alertDialog.addAction(cancel)
            alertDialog.addAction(openSetting)
            self.present(alertDialog, animated: true, completion: nil)
        default:
            print("")
        }
        

    }

    @IBAction func allowBtnTouched(_ sender: UIButton) {
        checkAuthorizationStatus()

    }
    
    
}

