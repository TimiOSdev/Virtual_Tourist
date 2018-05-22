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
var selectedAnnotation: MKPointAnnotation?
class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    var pin: [Pin] = []
    var dataController:DataController!
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 7000
    @IBOutlet weak var instructionText: UILabel!
    @IBOutlet weak var editOutlet: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
//            DestroysCoreDataMaintence(result)
            pin = result
            for object in pin {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: object.lat , longitude: object.long)
                mapView.addAnnotation(annotation)
            }
               mapView.reloadInputViews()
        }
    }
    
    func addDoubleTap() {
        
        //Long gesture will drop the pin
        let doubleTap = UILongPressGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
                doubleTap.numberOfTapsRequired = 2
        doubleTap.minimumPressDuration = 0.0
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
    }
    func savedPin (lat: Double, long: Double) {

        let pin = Pin(context: dataController.viewContext)
        pin.lat = lat
        pin.long = long
        pin.creationDate = Date()
        try? dataController.viewContext.save()
    }
    @IBAction func editPins(_ sender: UIBarButtonItem) {
        
        instructionText.text = "Tap once to delete"
    }
    //Maintence File
    fileprivate func DestroysCoreDataMaintence(_ result: [Pin]) {
        for object in result {
            dataController.viewContext.delete(object)
        }
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
        let annotation = MKPointAnnotation()
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print("This is the map gps coordinate\(touchCoordinate)")
        annotation.coordinate = CLLocationCoordinate2D(latitude: touchCoordinate.latitude , longitude: touchCoordinate.longitude)
        mapView.addAnnotation(annotation)
        //This will save the pin in coreData
        let lat = Double(touchCoordinate.latitude)
        let long = Double(touchCoordinate.longitude)
        savedPin(lat: lat, long: long)
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
