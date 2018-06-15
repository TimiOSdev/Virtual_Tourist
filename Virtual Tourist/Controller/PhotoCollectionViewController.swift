//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by sudo on 5/22/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage

private let reuseIdentifier = "ImageCollectionCell"


class PhotoCollectionViewController: UICollectionViewController {
    @IBOutlet var flowLayout: UICollectionView!
    var images = [UIImage]()
    var imagesSelected = [UIImage]()
    var ill = [UIImage]()
    var lat: Double = 0.0
    var long: Double = 0.0
    
    // ROLL TIDE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.dataSource = self
        self.collectionView?.allowsMultipleSelection = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(reloadCollectionImages))
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        getImageWith(lat: lat, long: long) { (image) in
            self.images = image
            if self.images.count == 9 {
                self.collectionView?.reloadData()
            }
            print(self.images.count)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return self.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        self.imagesSelected.append(self.images[indexPath.row])
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.red.cgColor
        if cell?.layer.borderColor == UIColor.red.cgColor && self.imagesSelected.count > 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete Selected", style: .plain, target: self, action: #selector(deletePhotos))
        }
 
    }
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
            imagesSelected.remove(at: indexPath.row)
        print(indexPath.row)
        print(self.imagesSelected.count)
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
        //        let memeImages = self.images[indexPath.row]
        let imageview:UIImageView = UIImageView(frame: CGRect(x: 1, y: 1, width: 135, height: 135))
        
        
        //    imageview.contentMode = UIViewContentMode.scaleAspectFit
        let image = self.images[indexPath.row]
        imageview.image = image
        cell.contentView.addSubview(imageview)
        return cell
    }
    
    // MARK: Functions
    
    
    
    
    @objc func getImageWith(lat: Double, long: Double, complete: @escaping ([UIImage])-> Void) {
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
        var images: [URL] = []
        // Fetch Request
        Alamofire.request("https://api.flickr.com/services/rest/", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if response.result.isSuccess {
                    let JSONback: JSON = JSON(response.result.value!)
                    print(JSONback)
                    var count = 0
                    repeat {
                        images.append(URL(string: JSONback["photos"]["photo"][count]["url_s"].stringValue)!)
                        if images.count == 0 {
                            return
                        }
                        Alamofire.request("\(images[count])").responseImage { response in
                            
                            if let image = response.result.value {
                                self.ill.append(image)
                                complete(self.ill)
                            }
                        }
                        count += 1
                    } while count <= 8
                    
                }else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
        }
    }
    
    func getImageWithAnd(lat: Double, long: Double, complete: @escaping ([UIImage])-> Void) {
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
        var images: [URL] = []
        // Fetch Request
        Alamofire.request("https://api.flickr.com/services/rest/", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if response.result.isSuccess {
                    let JSONback: JSON = JSON(response.result.value!)
                    var count = 0
                    
                    repeat {
                        images.append(URL(string: JSONback["photos"]["photo"][count]["url_s"].stringValue)!)
                        if images.count == 0 {
                            return
                        }
                        Alamofire.request("\(images[count])").responseImage { response in
                            
                            if let image = response.result.value {
                                self.ill.append(image)
                                complete(self.ill)
                            }
                        }
                        count += 1
                    } while count <= 8
                    
                }else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
        }
    }
    
    // MARK: OBJC functions
    
    @objc func reloadCollectionImages() {
        self.ill = []
        self.images = []
        
        getImageWith(lat: lat, long: long) { (image) in
            self.images = image
            if self.images.count == 8 {
                self.collectionView?.reloadData()
            }
            print(self.images.count)
            
        }
    }
    @objc func deletePhotos() {
  
        for i in self.imagesSelected {
            if self.images.contains(i) {
                let killImage = self.images.index(of: i)
                self.images.remove(at: killImage!)
            }
        }
        self.collectionView?.reloadData()
    }
}








