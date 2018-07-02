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
//MARK: GLOBAL VARIABLES

var isEditing = false
class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    var lat:Double?
    var long: Double?
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 10000
    var pin: [Pin] = []
    var dataController:DataController!
    var selectedPin:MKAnnotation?
    
    //MARK: CONNECTION OUTLETS
    @IBOutlet weak var instructionText: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: ROLL TIDE
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPins))
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            //                                    DestroysCoreDataMaintence(result)
            pin = result
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
        addHoldTap()
        self.navigationItem.rightBarButtonItem?.title = "Edit"
    }
    //MARK: ADD and DELETE Pin and functions
    func addHoldTap() {
        
        //Long gesture will drop the pin
        let singleHold = UILongPressGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        singleHold.minimumPressDuration = 0.8
        singleHold.delaysTouchesBegan = true
        singleHold.delegate = self
        mapView.addGestureRecognizer(singleHold)
    }
    func savedPin (lat: Double, long: Double) {
        
        let pin = Pin(context: dataController.viewContext)
        pin.lat = lat
        pin.long = long
        pin.creationDate = Date()
        try? dataController.viewContext.save()
    }
    
    fileprivate func pinRemovalOn(_ sellected: MKAnnotation?) {
        for pin in pin {
            if sellected?.coordinate.latitude == pin.lat && sellected?.coordinate.longitude == pin.long {
                let pin = pin
                dataController.viewContext.delete(pin)
                try? dataController.viewContext.save()
                self.mapView.reloadInputViews()
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // If selection and not true it will move to PhotoAlbumViewController
        if isEditing == true {
            selectedPin = mapView.selectedAnnotations.first
            pinRemovalOn(selectedPin)
            mapView.removeAnnotation(selectedPin!)
            
        }else {
            lat = view.annotation?.coordinate.latitude
            long = view.annotation?.coordinate.longitude
            performSegue(withIdentifier: "toPhoto", sender: self)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhoto" {
            let destinationVC = segue.destination as! PhotoAlbumViewController
            destinationVC.lat = lat!
            destinationVC.long = long!
            destinationVC.dataController = self.dataController
            
            
        }
    }
    //Maintence File will delete in CoreData
    fileprivate func DestroysCoreDataMaintence(_ result: [Pin]) {
        for object in result {
            dataController.viewContext.delete(object)
        }
    }
}
extension MapVC: MKMapViewDelegate{
    //This will center users on the map
    func centerMapOnUserLocation() {
        
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    //MARK: OBJC objects
    @objc func dropPin(sender: UITapGestureRecognizer) {
        //Drop pin on the map
        if isEditing == false {
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
        
    }
    @objc func editPins() {
        
        isEditing = true
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
        instructionText.text = "Double tap to delete"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEditing))
    }
    @objc func doneEditing() {
        
        isEditing = false
        instructionText.text = "Press & hold to drop pin"
        viewDidLoad()
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

