//
//  ST_LocationManager.swift
//  UserLocationProfile
//
//  Created by Joeun Kim on 6/11/22.
//

import CoreLocation

protocol LocationManagerDelegate: AnyObject { // AnyObject: to ensure delegate is weak reference
    func locationDidUpdateWith(city: String, state: String, country: String, countryCode: String)
}

class LocationManager : NSObject {
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
    weak var delegate: LocationManagerDelegate?
    
//    static let shared: LocationManager = {
//        let instance = LocationManager()
//        return instance
//    }()
    
    static let shared = LocationManager()
    private override init() {
        super.init()
        self.locationManager = CLLocationManager()
        
        guard let locationManager = self.locationManager else {
            return
        }

        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
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
    
    func getAccuracyAuthorization() -> CLAccuracyAuthorization {
        if let locationManager = locationManager {
            switch locationManager.accuracyAuthorization {
            case .fullAccuracy:
                print("full")
            case .reducedAccuracy:
                print("reduced")
            }
            return locationManager.accuracyAuthorization
        }
        return .reducedAccuracy
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
                    print(firstPlacemark.administrativeArea)
                    print(firstPlacemark.subAdministrativeArea) // county
                    print(firstPlacemark.isoCountryCode) // country code
                    
                    // Model -> Controller : Notify location update to delegator
                    self.delegate?.locationDidUpdateWith(city: "\(firstPlacemark.subLocality ?? "N/A")", state: "\(firstPlacemark.locality ?? "N/A")", country: "\(firstPlacemark.country ?? "N/A")", countryCode: "\(firstPlacemark.isoCountryCode ?? "N/A")")
                }
            }
        })
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("\(#function)")
        guard let locationManager = locationManager else { return }
        
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        JKLog.log(message: "\(getAccuracyAuthorization())")
        if let lastLocation = locations.last {
            JKLog.log(message: "long: \(lastLocation.coordinate.longitude) | lat: \(lastLocation.coordinate.latitude)")
        }
        // convert lon,lat to address
        DispatchQueue.global(qos: .userInteractive).async {
            JKLog.log(message: "\(Thread.current)") // MARK: global queue
            self.getAddress()
            // chance of crash : delegator VC might not be in memory at this moment -> use notification center instead
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let locationManager = locationManager else {
            return
        }
        locationManager.requestLocation()
    }
}

extension LocationManager {
    enum PermissionRequestResult {
        case granted, notDetermined, appNotAllowed, systemNotAllowed
    }
}
