//
//  LocationViewModel.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/28/22.
//

import Foundation

protocol LocationViewModelDelegate: AnyObject { // AnyObject: to ensure delegate is weak reference
    func locationDidUpdateWith2(city: String, state: String, country: String, countryCode: String)
    func authorizationDidUpdateTo(permission: LocationManager.PermissionRequestResult)
}

class LocationViewModel: LocationManagerDelegate {
    
    var locationManager: LocationManager!
    weak var delegate: LocationViewModelDelegate?
    
    init() {
        locationManager = LocationManager.shared
        locationManager.delegate = self
        
    }
    
    func checkLocationServiceAuthorization() {
        locationManager.checkAuthorizationStatus()
    }
    
    func locationDidUpdateWith(city: String, state: String, country: String, countryCode: String) {
        JKLog.log(message: "LocationViewModel")
        self.delegate?.locationDidUpdateWith2(city: city, state: state, country: country, countryCode: countryCode)
    }
    
    func authorizationDidCheck(permission: LocationManager.PermissionRequestResult) {
        self.delegate?.authorizationDidUpdateTo(permission: permission)
    }
    
}
