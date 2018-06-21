//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by sudo on 5/22/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import AlamofireImage
import Foundation
private let reuseIdentifier = "ImageCollectionCell"


class PhotoCollectionViewController: UICollectionViewController {
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var flowLayout: UICollectionView!
    var killer = Photo()
//    var images: Photo!
    var imagesData = [UIImage]()
    var imagesSelected = [UIImage]()
    var ill = [NSData]()
    var lat: Double = 0.0
      var dataController:DataController!
    var long: Double = 0.0
    
    // ROLL TIDE

    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.collectionView?.dataSource = self
        self.collectionView?.allowsMultipleSelection = true
        //        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector())
        //        let imager = Photo(context: dataController.viewContext)
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "imageData", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        
//        if let result = try? dataController.viewContext.fetch(fetchRequest) {
//            images = result
//            for object in images {
//                print(object)
//                //                let annotation = MKPointAnnotation()
//                //                annotation.coordinate = CLLocationCoordinate2D(latitude: object.lat , longitude: object.long)
//                //                mapView.addAnnotation(annotation)
//            }
//            collectionView?.reloadData()
//        }
    }
    

    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        getImageWith(lat: lat, long: long) {(image) in
           
 
            self.imagesData.append(image)
            print(self.imagesData.count)
            self.collectionView?.reloadData()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func savedImagesInPersistance (image: UIImage) {
        
        print(image)
    }
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return self.imagesData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        //        self.imagesSelected.append(self.images[indexPath.row])
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.red.cgColor
        if cell?.layer.borderColor == UIColor.red.cgColor && self.imagesSelected.count > 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete Selected", style: .plain, target: self, action: #selector(deletePhotos))
        }
        
    }
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        imagesSelected.remove(at: indexPath.row)
        if cell?.isSelected == false {
            cell?.layer.borderColor = UIColor.clear.cgColor
            print(self.imagesSelected)
            if self.imagesSelected.count == 0 {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(getImageWith))
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete Selected", style: .plain, target: self, action: #selector(deletePhotos))
            }
            
        }
        
    }
    
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = UICollectionViewCell()
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
                let imageview:UIImageView = UIImageView(frame: CGRect(x: 1, y: 1, width: 120, height: 120))
                let image = self.imagesData[indexPath.row]

                imageview.image = image
                cell.contentView.addSubview(imageview)
        return cell
    }
    
    // MARK: Functions
    
    
    

    @objc func getImageWith(lat: Double, long: Double, complete: @escaping (UIImage)-> Void) {
        /**
         Request
         get https://api.flickr.com/services/rest/
         */
        // Add URL parameters
        let urlParams = [
            "method":"flickr.photos.search",
            "api_key":"77693cba952ebe5dc5a74aef95f6921b",
            "lat":"\(lat)",
            "lon":"\(long)",
            "extras":"url_s",
            "format":"json",
            "nojsoncallback":"1"
        ]
        var imageURLs: [URL] = []
        // Fetch Request
        Alamofire.request("https://api.flickr.com/services/rest/", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if response.result.isSuccess {
                    let JSONback: JSON = JSON(response.result.value!)
                    print(JSONback)
                    var count = 0
                    repeat {
                        imageURLs.append(URL(string: JSONback["photos"]["photo"][count]["url_s"].stringValue)!)
                        guard imageURLs.count != 0 else { return }
                        Alamofire.request("\(imageURLs[count])").responseImage { response in
                            
                            complete(response.result.value!)
                        }
                        count += 1
                    } while count <= 8
                    
                }else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
                print(self.imagesData)
        }
    }
    
    
    
    // MARK: OBJC functions
    
    //    @objc func reloadCollectionImages() {
    //        self.ill = []
    //        self.images = []
    //
    //        getImageWith(lat: lat, long: long) { (image) in
    //            self.images = image
    //            if self.images.count == 8 {
    //                self.collectionView?.reloadData()
    //            }
    //            print(self.images.count)
    //
    //        }
    //    }
    @objc func deletePhotos() {
        
        //        for i in self.imagesSelected {
        //            if self.images.contains(i) {
        //                let killImage = self.images.index(of: i)
        //                self.images.remove(at: killImage!)
        //            }
        //        }
        //        self.collectionView?.reloadData()
    }
    

}








