//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by sudo on 5/22/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit
import CoreData
import Foundation
private let reuseIdentifier = "ImageCollectionCell"

class PhotoAlbumViewController: UICollectionViewController {
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var flowLayout: UICollectionView!
    @IBOutlet weak var imageOUT: UIImageView!
    var imageData: Data?
    let downloadingImage = ProfileViewController()
    var pin: Pin!
    var images: [Photo] = []
    var dataController:DataController!
    var imagesData = [UIImage]()
    var imagesSelected = [UIImage]()
    var lat: Double = 0.0
    var long: Double = 0.0
    
    // ROLL TIDE
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.imagesData = []
        if self.images.count == 0 {
            self.downloadingImage.getImageWith(lat: lat, long: long, controller: dataController) { (images) in
                let photo = Photo(context: self.dataController.viewContext)
                photo.imageData = images
                photo.pin = self.pin
                try? self.dataController.viewContext.save()
                
                self.imagesData.append(UIImage(data: images)!)
                self.collectionView?.reloadData()
                
            }
           
        }
        let width = (view.frame.size.width - 20) / 3
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        self.collectionView?.dataSource = self
        self.collectionView?.allowsMultipleSelection = true
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
//        let predicate = NSPredicate(format: "name IN %@", child)
        let sortDescriptor = NSSortDescriptor(key: "imageData", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
               images = result

            for images in images {
                self.imagesData.append(UIImage(data: images.imageData!)!)
               
            }


    }

self.collectionView?.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        print("Save on back")
        try? dataController.viewContext.save()
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
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(deletePhotos))
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete Selected", style: .plain, target: self, action: #selector(deletePhotos))
            }
            
        }
        
    }
    
    
    fileprivate func DestroysCoreDataMaintence(_ result: [Photo]) {
        for object in result {
            dataController.viewContext.delete(object)
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //        let cell = UICollectionViewCell()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let imageview:UIImageView = UIImageView(frame: CGRect(x: 1, y: 1, width: 120, height: 120))
        if self.imagesData.count > 0 {
             let image = self.imagesData[indexPath.row]
            imageview.image = image
            cell.contentView.addSubview(imageview)
        }
        return cell
    }

    
    // MARK: Functions

    
    
    
    // MARK: OBJC functions
    
        @objc func reloadCollectionImages() {
//            self.ill = []
//            self.images = []

//            downloadingImage.getImageWith(lat: lat, long: long, controller: dataController) { (image) in
//                self.imagesData = UIImage(data: image)
//                if self.images.count == 8 {
//                    self.collectionView?.reloadData()
//                }
//                print(self.images.count)
//
//            }
            }
    @objc func deletePhotos() {

//                for i in self.imagesSelected {
//                    if self.images.contains(i) {
//                        let killImage = self.images.index(of: i)
//                        self.images.remove(at: killImage!)
//                    }
//                }
//                self.collectionView?.reloadData()
    }
}








