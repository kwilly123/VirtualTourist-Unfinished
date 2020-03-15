//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-10.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import MapKit

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationRetrieved: CLLocationCoordinate2D?
    var locationTitle: String?
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isUserInteractionEnabled = false
        print(locationRetrieved ?? "nil")
        self.collectionView.register(PhotoViewCell.self, forCellWithReuseIdentifier: "cell")
        if let locationRetrieved = locationRetrieved {
            pin(coordinate: locationRetrieved)
        } else {
            let alert = UIAlertController(title: "Error", message: "Error getting location. Go back to previous view.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
        
        FlickrClient.searchPhotos(lat: locationRetrieved!.latitude, lon: locationRetrieved!.longitude, totalPageAmt: 2) { (photos, totalPages, error) in
            if photos.count > 0 {
                for photo in photos {
                    self.image = photo.photoImage
                }
            }
        }
    }
    
    func pin(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = locationTitle
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: true)
            self.mapView.regionThatFits(region)
        }
    }

}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoViewCell
        cell?.imageView.image = image
        print(image!)
        return cell!
    }
}
