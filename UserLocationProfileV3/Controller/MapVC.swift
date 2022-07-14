//
//  MapVC.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 7/13/22.
//

import UIKit
import MapKit

class MapVC: UIViewController, LocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = LocationManager.shared // Service provider

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        
        
        

    }
    
    func locationDidUpdateWith(location: CLLocation?) {
        print("...")
        guard let location = location else { return }
//        let span = MKCoordinateSpan(latitudeDelta: coordinate.latitude, longitudeDelta: coordinate.longitude)
//        let region = MKCoordinateRegion(center: coordinate, span: span)
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil {
                if let firstPlacemark = placemarks?[0] {
                    annotation.title = "\(firstPlacemark.subLocality != nil ? firstPlacemark.subLocality!+"," : "" )                                 \(firstPlacemark.locality != nil ? firstPlacemark.locality!+"," : "")                                        \(firstPlacemark.country ?? "")"
                    self.mapView.addAnnotation(annotation)

                }
            }
        })
        
//        annotation.title = "You Are Here!"
//        mapView.addAnnotation(annotation)
        
    }
    
    func locationDidUpdateWith(city: String, state: String, country: String, countryCode: String) {
        // NOT USING HERE. CURRENTLY TESTING MAPKIT WITH THIS DELEGATE
    }
    


}
