//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by sudo on 3/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    var dataController:DataController!
    
    
  

    let annotation = MKPointAnnotation()
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 7000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        //NSFetchRequest  SELECT Query
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
//        // NSSortDesciotor is like ORDER by in MYSQL
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
//            Notebooks and result if there is one there
            PinPinSaved = result
//            reload tableView or whatever you are using
            mapView.reloadInputViews()
        }

    }
    func addDoubleTap() {
        //Long gesture will drop the pin
        let doubleTap = UILongPressGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
//        doubleTap.numberOfTapsRequired = 1
        doubleTap.minimumPressDuration = 0.5
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
  
    }
    func addPin (lat: Double, long: Double) {
        let pin = Pin(context: dataController.viewContext)
        pin.lat = lat
        pin.long = long
        pin.creationDate = Date()
        try? dataController.viewContext.save()
    }


}
extension MapVC: MKMapViewDelegate{
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    @objc func dropPin(sender: UITapGestureRecognizer) {
        //Drop pin on the map
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print("This is the map gps coordinate\(touchCoordinate)")
        annotation.coordinate = CLLocationCoordinate2D(latitude: touchCoordinate.latitude , longitude: touchCoordinate.longitude)
        mapView.addAnnotation(annotation)
        //This will save the pin in coreData
        let lat = Double(touchCoordinate.latitude)
        let long = Double(touchCoordinate.longitude)
        print("Printing this \(lat)")
        addPin(lat: lat, long: long)
    }


}
extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
