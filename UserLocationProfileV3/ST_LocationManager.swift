//
//  ST_LocationManager.swift
//  UserLocationProfile
//
//  Created by Joeun Kim on 6/11/22.
//

import UIKit
import CoreLocation

protocol ST_LocationManagerDelegate {
    func locationDidUpdateWith(city: String, state: String, country: String)
//    func locationDidChangePermission(to permission:ST_LocationManager.PermissionRequestResult)
}

class ST_LocationManager: NSObject {
    /*
     class var sharedInstance: LocationService {
             struct Static {
                 static var onceToken: dispatch_once_t = 0
                 
                 static var instance: LocationService? = nil
             }
             dispatch_once(&Static.onceToken) {
                 Static.instance = LocationService()
             }
             return Static.instance!
         }
     */
    
    private var locationManager: CLLocationManager?
    // https://stackoverflow.com/questions/27532897/find-delegate-in-a-swift-array-of-delegates
    var delegate: ST_LocationManagerDelegate?
    
    static let shared: ST_LocationManager = {
        let instance = ST_LocationManager()
        return instance
    }()
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        JKLog.log(message: "")
        
        guard let locationManager = self.locationManager else {
            return
        }

        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
    }
    

    func checkAuthorizationStatus() -> PermissionRequestResult {
        print("check authorization status...")
        guard let locationManager = locationManager else {
            print("failed to get location manager instance")
            return .notDetermined
        }


        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                return .granted
            case .notDetermined:
                print("not determined")
                return .notDetermined
            case .denied, .restricted:
                print("denied/restricted")
                return .appNotAllowed
            }
        } else {
            return .systemNotAllowed
        }
    }
    
    func requestWhenInUse() {
        guard let locationManager = locationManager else {
            return
        }

        locationManager.requestWhenInUseAuthorization()
    }
    
    // TODO: check usage
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        guard let locationManager = locationManager else {
            return .notDetermined
        }
        
        return locationManager.authorizationStatus

    }
    
    
    func getAddress() {
        JKLog.log(message: "\(Thread.current)")
        
        guard let locationManagerLocation = locationManager?.location else {
            return
        }

        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(locationManagerLocation, completionHandler: { (placemarks, error) in
            if error == nil {
                if let firstPlacemark = placemarks?[0] {
                    print(firstPlacemark.country)
                    print(firstPlacemark.locality) // state
                    print(firstPlacemark.subLocality) // city
                    self.delegate?.locationDidUpdateWith(city: "\(firstPlacemark.subLocality ?? "N/A")", state: "\(firstPlacemark.locality ?? "N/A")", country: "\(firstPlacemark.country ?? "N/A")")
                }
                

            }
        })
        
        
    }


}

extension ST_LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("\(#function)")
        guard let locationManager = locationManager else { return }
        
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        
//        switch locationManager.authorizationStatus {
//        case .authorizedAlways, .authorizedWhenInUse:
//            delegate?.locationDidChangePermission(to: .granted)
//        case .denied, .restricted:
//            delegate?.locationDidChangePermission(to: .appNotAllowed)
//        case .notDetermined:
//            delegate?.locationDidChangePermission(to: .notDetermined)
//        default:
//            delegate?.locationDidChangePermission(to: .systemNotAllowed)
//        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            JKLog.log(message: "long: \(lastLocation.coordinate.longitude) | lat: \(lastLocation.coordinate.latitude)")
        }
        // convert lon,lat to address
        DispatchQueue.global(qos: .utility).async {
            JKLog.log(message: "\(Thread.current)") // MARK: global queue
            self.getAddress()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let locationManager = locationManager else {
            return
        }
        locationManager.requestLocation()
    }
    
    
}

extension ST_LocationManager {
    enum PermissionRequestResult {
        case granted, notDetermined, appNotAllowed, systemNotAllowed
    }
    
}

//extension ST_LocationManagerDelegate {
//    func locationDidUpdateWith(city: String, state: String, country: String) {
//
//    }
////    func locationDidChangePermission(to permission:ST_LocationManager.PermissionRequestResult) {
////
////    }
//}
