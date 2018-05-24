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

private let reuseIdentifier = "Cell"

class PhotoCollectionViewController: UICollectionViewController {

    
    
    
    
    var imagedDownload = [Any]()
    
    let downloader = ImageDownloader()
    let filter = AspectScaledToFillSizeCircleFilter(size: CGSize(width: 100.0, height: 100.0))
    var images = [URL]()
    var lat: Double = 0.0
    var long: Double = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        
        print(imagedDownload.count)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
       
        sendRequestRequest(lat: lat, long: long)
        print("\(imagedDownload.count)")
      
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//        cell.imageCell.af_setImage(withURL: URL(string: "\(imageURL)")!)
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

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
    func sendRequestRequest(lat: Double, long: Double) {
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
//            "auth_token":"72157697160689435-baf44d1d99ed2e07",
//            "api_sig":"4c5ffd85933b15ad87728424caffc26a",
            ]
        
        // Fetch Request
        Alamofire.request("https://api.flickr.com/services/rest/", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if response.result.isSuccess {
                    let JSONback: JSON = JSON(response.value!)
                    var count = 0
                    repeat {
                        self.images.append(URL(string: JSONback["photos"]["photo"][count]["url_s"].stringValue)!)
                        
                        Alamofire.request("\(self.images[count])").responseImage { response in
//                            debugPrint(response)
                            if let image = response.result.value {
                                print("\(image)")
                                self.imagedDownload.append(image)
                                print("\(self.imagedDownload.count)")
                                
                            }
                        }
                        
                        count += 1
                    } while count <= 20
                   
                  
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
        }
       
    }
    
    

    

    
    

}
