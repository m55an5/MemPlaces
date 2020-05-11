//
//  ViewController.swift
//  MemPlaces
//
//  Created by Manjot S Sandhu on 17/4/20.
//  Copyright © 2020 Manjot S Sandhu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol AddNewPlaceDelegate {
    func userEnteredAPlace(place : Places)
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var delegate : AddNewPlaceDelegate?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedPlace: Places?
    
    @IBOutlet weak var map: MKMapView!
    
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(gestureRecognizer:)))
        uilpgr.minimumPressDuration = 2
        map.addGestureRecognizer(uilpgr)
        
        if selectedPlace == nil {
            
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        }else{
            // Get Place details to display on Map
            
            if selectedPlace != nil {
                if let name = selectedPlace!.name {
                    if let lat = selectedPlace?.lat {
                        if let lon = selectedPlace?.lon {
                            if let latitude = Double(lat) {
                                if let longitude = Double(lon) {
                                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

                                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                                    let region = MKCoordinateRegion(center: coordinate, span: span)

                                    self.map.setRegion(region, animated: true)

                                    let annotation = MKPointAnnotation()
                                    annotation.coordinate = coordinate
                                    annotation.title = name

                                    self.map.addAnnotation(annotation)
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }

    @objc func longPress(gestureRecognizer: UIGestureRecognizer){
        
        // to avoid more than one press recognition
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
        
            let touchPoint = gestureRecognizer.location(in: self.map)
            
            let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
            
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            var title = ""
            
            CLGeocoder().reverseGeocodeLocation(location) {
                (placeMarks, error) in
                if error != nil{
                    print(error!)
                }else{
                    
                    if let placemark = placeMarks?[0]{
                        if placemark.locality != nil {
                            title += placemark.locality! + " "
                        }
                    }else{
                        print("didnt return anything in placemark")
                    }
                }
                
                if title == "" {
                    title = "Added \(NSDate())"
                }
                let newPlace = Places(context: self.context)
                newPlace.name = title
                newPlace.lat = String(newCoordinate.latitude)
                newPlace.lon = String(newCoordinate.longitude)
                
                self.delegate?.userEnteredAPlace(place: newPlace)

            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinate
            annotation.title = title
            
            self.map.addAnnotation(annotation)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.map.setRegion(region, animated: true)
        
    }

}

