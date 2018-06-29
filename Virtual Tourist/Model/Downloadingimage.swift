//
//  Downloading image.swift
//  Virtual Tourist
//
//  Created by Tim McEwan on 6/25/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import AlamofireImage


 private var appDelegate = UIApplication.shared.delegate as! AppDelegate


class ProfileViewController: UIViewController {
    func getImageWith(lat: Double, long: Double, controller: DataController, complete:@escaping (Data)-> Void) {
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
                  
                    
             
                    
                    var count = 0
                    repeat {
                        
                        imageURLs.append(URL(string: JSONback["photos"]["photo"][count]["url_s"].stringValue)!)
                        
                        Alamofire.request("\(imageURLs[count])").responseData { response in
                            
                            if let image = response.data {
           
                                complete(image)
                                
                            }
                        }
                        count += 1
                    } while count <= 11
               
                }else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
              
        }
    
}
    
    
    
    
    func getImageWithNew(lat: Double, long: Double, controller: DataController, complete:@escaping (Data)-> Void) {
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
                    
                    
                    
                    
                    var count = 0
                    repeat {
                        
                        imageURLs.append(URL(string: JSONback["photos"]["photo"][Int(arc4random_uniform(60))]["url_s"].stringValue)!)
                        
                        Alamofire.request("\(imageURLs[count])").responseData { response in
                            
                            if let image = response.data {
                                
                                complete(image)
                                
                            }
                        }
                        count += 1
                    } while count <= 11
                    
                }else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
                
        }
        
    }
    
}
