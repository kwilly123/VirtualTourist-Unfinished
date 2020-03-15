//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-09.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController {
    
    var sendCoordinates: CLLocationCoordinate2D?
    var sendLocationTitle: String?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func longTap(sender: UIGestureRecognizer) {
        if sender.state == .began {
            let locationTappedInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationTappedInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
            sendCoordinates = locationOnMap
        }
    }
    
    func addAnnotation(location: CLLocationCoordinate2D) {
        let coordinates = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        CLGeocoder().reverseGeocodeLocation(coordinates) { (placemark, error) in
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: "Location doesn't exist", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            var placeMark: CLPlacemark!
            placeMark = placemark?[0]
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "\(placeMark.locality ?? "No City"), \(placeMark.administrativeArea ?? "No State")"
            self.sendLocationTitle = annotation.title
            annotation.subtitle = "See Collection"
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
}

extension TravelMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.tintColor = .black
            pinView?.pinTintColor = .blue
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Tapped PIN")
        let vc = storyboard?.instantiateViewController(identifier: "CollectionViewController") as! CollectionViewController
        vc.locationRetrieved = sendCoordinates
        vc.locationTitle = sendLocationTitle
        navigationController?.pushViewController(vc, animated: true)
    }
}

