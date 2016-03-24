//
//  ViewController.swift
//  gob-swift-eval
//
//  Created by Etienne De Ladonchamps on 26/02/2016.
//  Copyright © 2016 Etienne De Ladonchamps. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CustomLocationManagerDelegate, MKMapViewDelegate {

    let regionRadius: CLLocationDistance = 1000
    var locationManager: CustomLocationManager?
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 48.872473, longitude: 2.387603)
    var userPoint: MKPointAnnotation = MKPointAnnotation()
    var mainButtonMode: String = "add"
    
    
    let customPedometer: CustomPedometer = CustomPedometer(useNatif: false)
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deposeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // LocationManager
        self.locationManager = CustomLocationManager(useNatif: false)
        self.locationManager?.delegate = self
        self.locationManager?.start()

        // Map
        let initialLocation = CLLocation(latitude: 48.872473, longitude: 2.387603)
        self.mapView.delegate = self
        centerMapOnLocation(initialLocation)
        
        self.userPoint.coordinate = CLLocationCoordinate2D(latitude: 48.872473, longitude: 2.387603)
        self.userPoint.title = "Me"
        self.userPoint.subtitle = "That's you !"
        self.mapView.addAnnotation(self.userPoint)
        
        
        
//        let steps = self.customPedometer.getPedometerData(NSDate(), toDate: NSDate()).numberOfSteps
        //let distance = self.customPedometer.getPedometerData(NSDate(), toDate: NSDate()).distance
        //let currentCadence = self.customPedometer.getPedometerData(NSDate(), toDate: NSDate()).currentCadence
        //let floorsAscended = self.customPedometer.getPedometerData(NSDate(), toDate: NSDate()).floorsAscended
        //let floorsDescended = self.customPedometer.getPedometerData(NSDate(), toDate: NSDate()).floorsDescended
        //let start = self.customPedometer.getPedometerData(NSDate(), toDate: NSDate()).startDate
        //let end = self.customPedometer.getPedometerData(NSDate(), toDate: NSDate()).endDate
        
//        print("------------steps :", steps);
        //print("steps :", steps, "distance :", distance, "Cadence :",currentCadence, "Ascended", floorsAscended, "Descended", floorsDescended)
        //print(start, " / ", end);
        


    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func setButtonMode(mode: String) {
        if mode == "add" {
            self.deposeButton.backgroundColor = UIColor(colorLiteralRed: 0.2, green: 0.25, blue: 0.41, alpha: 1)
            self.deposeButton.setTitle("Add", forState: .Normal)
        } else
        if mode == "center" {
            self.deposeButton.backgroundColor = UIColor(colorLiteralRed: 0.11, green: 0.48, blue: 0.8, alpha: 1)
            self.deposeButton.setTitle("Center", forState: .Normal)
        } else
        if mode == "transit" {
            self.deposeButton.backgroundColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 0.5)
            self.deposeButton.setTitle("", forState: .Normal)
        }
        self.mainButtonMode = mode
    }
    
    // MARK: - Button Touch
    
    @IBAction func addMarker(sender: AnyObject) {
        let mode = self.mainButtonMode
        if mode == "add" {
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.userLocation
            annotation.title = "Test"
            annotation.subtitle = "Hey"
            
            self.mapView.addAnnotation(annotation)
        } else
        if mode == "center" {
            self.mapView.setCenterCoordinate(self.userLocation, animated: true)
            self.setButtonMode("add")
        } else
        if mode == "center" {
            // Do nothing
        }
    }
    
    
    // MARK: - LocationDelegate
    
    func customLocationManager(manager: CustomLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0].coordinate
        // print("location udated \(location.latitude) - \(location.longitude)")
        self.userLocation = locations[0].coordinate
        if self.mainButtonMode == "add" {
            self.mapView.setCenterCoordinate(self.userLocation, animated: false)
        }
        self.userPoint.coordinate = location
    }
    
    func customLocationManagerDidGetAuthorization(manager: CustomLocationManager)
    {
        self.locationManager?.startUpdateCustomLocation()
    }
    
    // MARK: - MapDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if self.userPoint as MKAnnotation === annotation  {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("user")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "user")
                annotationView!.canShowCallout = true
            }
            else {
                annotationView!.annotation = annotation
            }
            
            annotationView!.image = UIImage(named: "Me")
            
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        print("\(mapView.centerCoordinate.latitude) - \(mapView.centerCoordinate.longitude)")
        let centerCoord = mapView.centerCoordinate
        let userCoord = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
        let test = CLLocation(latitude: centerCoord.latitude, longitude: centerCoord.longitude)
        
        let distance = test.distanceFromLocation(userCoord)
        print("distance : \(distance)")
        if distance < 50 {
            self.setButtonMode("add")
        } else {
            self.setButtonMode("center")
        }
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//        print("------ \(mapView.centerCoordinate.latitude) - \(mapView.centerCoordinate.longitude)")
//        print("change region")
        
        self.setButtonMode("transit")
    }
    
    
    
    
    
}

