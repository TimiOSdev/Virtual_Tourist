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
import Foundation
var selectedAnnotation: MKPointAnnotation?
var isEditing = false

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    var lat:Double?
    var long: Double?
    var selectPins = [MKAnnotation]()
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 10000
    var pin: [Pin] = []
    var dataController:DataController!
    
    @IBOutlet weak var instructionText: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedAnnotation:MKAnnotation?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPins))
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addHoldTap()
             deleteHoldTap()
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            //                        DestroysCoreDataMaintence(result)
            pin = result
            //                        pin.removeAll(keepingCapacity: false)
            //                        pin.removeAll()
            for object in pin {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: object.lat , longitude: object.long)
                mapView.addAnnotation(annotation)
            }
            mapView.reloadInputViews()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem?.title = "Edit"
    }
    
    @IBAction func setPin(sender: UILongPressGestureRecognizer) {
        
    }
    
    func addHoldTap() {
        
        //Long gesture will drop the pin
        let doubleTap = UILongPressGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 0
        doubleTap.minimumPressDuration = 0.5
        doubleTap.delaysTouchesBegan = true
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
        
        
    }
    func deleteHoldTap() {
        
        //Long gesture will drop the pin
        let doubleTap = UILongPressGestureRecognizer(target: self, action: #selector(removePin(sender:)))
        doubleTap.numberOfTapsRequired = 0
        doubleTap.minimumPressDuration = 0.1
        doubleTap.delaysTouchesBegan = true
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
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditing == true {
            return
        }else {
            lat = view.annotation?.coordinate.latitude
            long = view.annotation?.coordinate.longitude
            performSegue(withIdentifier: "toPhoto", sender: self)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhoto" {
            
            let destinationVC = segue.destination as! PhotoCollectionViewController
            destinationVC.lat = lat!
            destinationVC.long = long!
        }
    }
    
    //Maintence File
    fileprivate func DestroysCoreDataMaintence(_ result: [Pin]) {
        for object in result {
            dataController.viewContext.delete(object)
        }
    }
    @objc func editPins() {
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
        isEditing = true
   
        instructionText.text = "Tap to select then tap and hold to delete"
        //        mapView.removeAnnotations()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEditing))
    }
    @objc func doneEditing() {
        
        instructionText.text = "Press & hold to drop pin"
        isEditing = false
        self.viewDidLoad()
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
        if sender.state == UIGestureRecognizerState.began {
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
    @objc func removePin(sender: UITapGestureRecognizer) {
        //Drop pin on the map
        let selectedPin = mapView.selectedAnnotations.first
        if selectedPin != nil {
            mapView.removeAnnotation(selectedPin!)
        }
        
        
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

