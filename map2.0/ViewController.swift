//
//  ViewController.swift
//  map2.0
//
//  Created by Benedict on 28/01/2020.
//  Copyright © 2020 Benedict. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import QuartzCore
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topLat: UILabel!
    @IBOutlet weak var leftLong: UILabel!
    @IBOutlet weak var bottomLat: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var schoolRegion: UIImageView!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    var topLeftPoint: CLLocationCoordinate2D?
    var bottomRightPoint: CLLocationCoordinate2D?
    var listOfSchool = [SchoolDetail]() {
        didSet {
            createAnnotations(mySchools: self.listOfSchool)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        centerViewOnUserLocation()
        // Do any additional setup after loading the view.
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // show alert telling them to turn it on
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTrackingUserLocation()
            break
        case .denied:
            //alert to turn on
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //show an alert
            break
        case .authorizedAlways:
            break

        }
    }
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func createAnnotations(mySchools: [SchoolDetail]){
        for location in mySchools {
            let annotations = MKPointAnnotation()
            annotations.title = location.school_name
            guard let currentLatitude: Float = location.latitude else {
                fatalError("Value was nil")
            }
            guard let currentLongitude: Float = location.longitude else {
                fatalError("Value was nil")
            }
            let curlat: CLLocationDegrees = Double(currentLatitude)
            let curlong: CLLocationDegrees = Double(currentLongitude)
            annotations.coordinate = CLLocationCoordinate2D(latitude: curlat ,longitude:  curlong)
            mapView.addAnnotation(annotations)
        }
    }

    func loadSchools(myCoordinates:Message) {
       let schoolRequest = APIRequest(endpoint: "map-demo")
        schoolRequest.getSchools(myCoordinates) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let schools):
                self?.listOfSchool = schools
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationServices()
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
            
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                //to do show alert informing user
                return
            }
            
            //guard let placemark = placemarks?.first else {
                //todo alert informing user
            //    return
            //}
            //let streetPostcode = placemark.postalCode ?? ""
            //mapView.annotationVisibleRect.bottomRight
            
            self.topLeftPoint = mapView.convert(CGPoint(x: 0, y: 0), toCoordinateFrom: self.mapView)
            self.bottomRightPoint = mapView.convert(mapView.annotationVisibleRect.bottomRight, toCoordinateFrom: self.mapView)
            
            guard let tlp = self.topLeftPoint?.latitude else {
                fatalError("Value was nil")
            }
            guard let llp = self.topLeftPoint?.longitude else {
                fatalError("Value was nil")
            }
            guard let blp = self.bottomRightPoint?.latitude else {
                fatalError("Value was nil")
            }
            guard let rlp = self.bottomRightPoint?.longitude else {
                fatalError("Value was nil")
            }
            let tlp_f = Float(tlp)
            let llp_f = Float(llp)
            let blp_f = Float(blp)
            let rlp_f = Float(rlp)
            
            let myCurrentCoordinates = Message(latnorth: tlp_f, latSouth: blp_f , longEast: rlp_f , longWest: llp_f)
            self.loadSchools(myCoordinates: myCurrentCoordinates)
            
        }
    }
}

extension CGRect {
  /// Sets and returns top left corner
  public var topLeft: CGPoint {
    get { return origin }
    set { origin = newValue }
  }
  
  /// Sets and returns top center point
  public var topCenter: CGPoint {
    get { return CGPoint(x: midX, y: minY) }
    set { origin = CGPoint(x: newValue.x - width / 2,
                           y: newValue.y) }
  }
  
  /// Returns bottom right corner
  public var bottomRight: CGPoint {
    get { return CGPoint(x: maxX, y: maxY) }
    set { origin = CGPoint(x: newValue.x - width,
                           y: newValue.y - height) }
  }
}

