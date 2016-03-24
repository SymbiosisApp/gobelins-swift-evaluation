//
//  Location.swift
//  gob-swift-eval
//
//  Created by Etienne De Ladonchamps on 26/02/2016.
//  Copyright © 2016 Etienne De Ladonchamps. All rights reserved.
//

import Foundation
import CoreLocation

class CustomLocationManager : NSObject, CLLocationManagerDelegate {
    var useNatif: Bool
    var natifLocationManager: CLLocationManager?
    var natifLocationManagerStatus: CLAuthorizationStatus? = nil
    var currentFakeLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 48.872473, longitude: 2.387603)
    var socket = Socket.sharedInstance
    weak var delegate: ViewController?
    weak var timer = NSTimer()
    
    init (useNatif:Bool) {
        self.useNatif = useNatif
        super.init()
    }
    
    func start () {
        if useNatif {
            // Init CLLocationManager
            self.natifLocationManager = CLLocationManager()
            self.natifLocationManager!.delegate = self
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                self.natifLocationManager!.requestAlwaysAuthorization()
            }
        } else {
            
            self.socket.io.on("UPDATE_ME_POSITION") {data, ack in
                let first = data[0] as! NSMutableDictionary
                var dict = [String : Any]()
                for (key, value) in first {
                    dict[key as! String] = value
                }
                let lat = dict["lat"] as! Double
                let lng = dict["lng"] as! Double
//                print(lat)
//                print(lng)
//                print("UPDATE_ME_POSITION \(lat) \(lng)")
                self.currentFakeLocation.latitude = lat
                self.currentFakeLocation.longitude = lng
                
                self.fakeLocationUpdate()
            }
            
            self.delegate?.customLocationManagerDidGetAuthorization(self)
        }
    }
    
    func startUpdateCustomLocation () {
        if self.useNatif {
            let status = self.natifLocationManagerStatus
            if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
                self.natifLocationManager!.startUpdatingLocation()
            }
        } else {
            self.startUpdatingFakeLocation()
        }
    }
    
    func startUpdatingFakeLocation () {
        self.fakeLocationUpdate()
    }
    
    func fakeLocationUpdate () {
//        let addLat = (drand48() - 0.5) / 10000.0
//        let addLon = (drand48() - 0.5) / 10000.0
//        self.currentFakeLocation.latitude += addLat
//        self.currentFakeLocation.longitude += addLon
        let altitude = 40.0
        let course = 0.0
        let timestamp = NSDate()
        
        let location = CLLocation(coordinate: self.currentFakeLocation, altitude: altitude, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, course: course, speed: 0.5, timestamp: timestamp)
        
        self.customLocationUpdate([location])
        
//        let nextUpdate = 5.3
//        timer = NSTimer.scheduledTimerWithTimeInterval(nextUpdate, target: self, selector: "fakeLocationUpdate", userInfo: nil, repeats: false)
    }
    
    
    func customLocationUpdate (locations: [CLLocation]) {
        if let delegate = self.delegate {
            delegate.customLocationManager(self, didUpdateLocations: locations)
        }
    }
    
    // MARK: CLLocationManager Protocol
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        self.natifLocationManagerStatus = status
        self.delegate?.customLocationManagerDidGetAuthorization(self)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.customLocationUpdate(locations)
    }
    
}

// MARK: CustomLocationManagerDelegate

protocol CustomLocationManagerDelegate: class {
    // On location update
    func customLocationManager(manager: CustomLocationManager, didUpdateLocations locations: [CLLocation])
    // On authorized
    func customLocationManagerDidGetAuthorization(manager: CustomLocationManager)
}