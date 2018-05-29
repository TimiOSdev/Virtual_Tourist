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
//import Foundation
private let reuseIdentifier = "ImageCollectionCell"

class PhotoCollectionViewController: UICollectionViewController {
  @IBOutlet var flowLayout: UICollectionView!

  
  
    var images = [UIImage]()
  var ill = [UIImage]()
    var lat: Double = 0.0
    var long: Double = 0.0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.

    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
      getImageWith(lat: lat, long: long) { (image) in
        self.images = image
        print(self.images)
        self.collectionView?.reloadData()
      }
    }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // Show the navigation bar on other view controllers
    self.images.removeAll()
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



      
      override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = UICollectionViewCell()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//        let memeImages = self.images[indexPath.row]
        let imageview:UIImageView = UIImageView(frame: CGRect(x: 1, y: 1, width: 125, height: 125))
        imageview.contentMode = UIViewContentMode.scaleAspectFit
        let image = self.images
        imageview.image = self.images[indexPath.row]
        cell.contentView.addSubview(imageview)
        
        return cell
      }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */


    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }


    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

  
  
  func getImageWith(lat: Double, long: Double, complete: @escaping ([UIImage])-> Void) {
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
            "nojsoncallback":"1",

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
                        
                      Alamofire.request("\(images[count])").responseImage { response in
                        
                            if let image = response.result.value {
                                self.ill.append(image)
                              complete(self.ill)
//                              self.collectionView?.reloadData()
                          
                            }
                            
                        }
                        
                        count += 1
                    } while count <= 5
                  
                }else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
              

        }


    }

}

    

    
    


