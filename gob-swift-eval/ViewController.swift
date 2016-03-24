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

    //----
    let customPedometer: CustomPedometer = CustomPedometer(useNatif: false)
    
    //----
    struct defaultsKeys {
        static let keyOne = "test 1"
        static let keyTwo = "test 2"
    }
    
    //----
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deposeButton: UIButton!
    
    //----
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var indexLabel: UILabel!

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
        
        // Pedometer
        let steps = self.customPedometer.getPedometerData(NSDate(), toDate: NSDate()).numberOfSteps
        print("steps :", steps);

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
    
    
    
    // MARK: -ProgressBar and Index
    func progress(){
        let progress = self.progressBar.frame
        var p = self.progressBar.frame
        
        let container = self.progressContainer.frame
        let maxY = container.height
        
        // 1000 = nomberOfstep until 100%
        var ped = CGFloat(3200)
        
        let index = CGFloat(ped/1000 - ((ped%1000)/1000))
        
        ped = ped%1000
        p.origin.y = maxY - (( ped * maxY) / 1000)
        
        
        print(ped)
        print(index)
        
        let indexString = "\(index)"
        self.indexLabel.text = indexString
        
        self.progressBar.frame = p
        self.view.addSubview(UIView(frame: progress))
    
    }
    
    
    
    // MARK: -Save Values
    func saveValue (){
        
        // ---- Tuto fpr save value on locals ----
        
        //let defaults = NSUserDefaults.standardUserDefaults()
        //defaults.setValue("Some String Value", forKey: defaultsKeys.keyOne)
        //defaults.setValue("Another String Value", forKey: defaultsKeys.keyTwo)
        //defaults.synchronize()
        //get string
        //let stringOne = defaults.stringForKey(defaultsKeys.keyOne)
        //print(stringOne) // Some String Value
        //let stringTwo = defaults.stringForKey(defaultsKeys.keyTwo)
        //print(stringTwo) // Another String Value
        
    }
    
    
    // MARK: -PostData
    func upload_request(){
        
        let url:NSURL = NSURL(string: "http://localhost:9000/locationDataSend/")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dictionaryData : [String:AnyObject] = ["id":1908098989,
            "nom":"yolo",
            "prenom":"yolo2",
            "couleur":1908098980,
            "date": "2016-11-11",
            "longitude":1908098980,
            "latitude":1908098980]
        var data = NSData()
        
        do{
            data = try NSJSONSerialization.dataWithJSONObject(dictionaryData, options: [])
            
        }catch let error as NSError {
            print(error)
        }
        
        request.HTTPBody = data
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let actuelError = error{
                print(actuelError)
            }
        }
        
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
        
        progress()  // ------>  FOR TEST
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

