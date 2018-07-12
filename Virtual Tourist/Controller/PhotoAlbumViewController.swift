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
    var imageData: Data?
    let downloadingImage = downloadingImagesVC()
    var photos: [Photo] = []
    var dataController:DataController!
    var imagesData = [UIImage]()
    var imagesSelected = [UIImage]()
    var lat: Double = 0.0
    var long: Double = 0.0
    
    // ROLL TIDE
    override func viewDidLoad() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(reloadCollectionImages))
        super.viewDidLoad()
        self.imagesData = []
        
        let width = (view.frame.size.width - 20) / 3
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        self.collectionView?.dataSource = self
        self.collectionView?.allowsMultipleSelection = true
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let predicate = NSPredicate(format: "pin IN[c] %@", photos)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "imageData", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            photos = result
            print("Fired")
            for images in photos {
                
                self.imagesData.append(UIImage(data: images.imageData!)!)
            }
        }
        if self.photos.count == 0 {
            self.downloadingImage.getImageWith(lat: lat, long: long, controller: dataController) { (images) in
                let photo = Photo(context: self.dataController.viewContext)
                photo.imageData = images
                try? self.dataController.viewContext.save()
                self.imagesData.append(UIImage(data: images)!)
                self.collectionView?.reloadData()
                
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
        
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.imagesData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        
        self.imagesSelected.append(self.imagesData[indexPath.row])
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.red.cgColor
      
        if cell?.layer.borderColor == UIColor.red.cgColor && self.imagesSelected.count > 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete Selected", style: .plain, target: self, action: #selector(DestroysCoreDataMaintence))
            
        }
        
        
    }
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        imagesSelected.remove(at: indexPath.row)
        if cell?.isSelected == false {
            cell?.layer.borderColor = UIColor.clear.cgColor
            print(self.imagesSelected)
            if self.imagesSelected.count == 0 {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(reloadCollectionImages))
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete Selected", style: .plain, target: self, action: #selector(deletePhotos))
                
            }
            
        }
        
    }
    fileprivate func DestroysCoreData() {
        let result = self.photos
        for object in result {
            if self.imagesSelected.contains(UIImage(data: object.imageData!)!) {
                            dataController.viewContext.delete(object)
                try? dataController.viewContext.save()
            }

        }
        collectionView?.reloadData()
    }
    
    @objc fileprivate func DestroysCoreDataMaintence() {
  
                        DestroysCoreData()
                        for i in self.imagesSelected {
                            if self.imagesData.contains(i) {
                                let killImage = self.imagesData.index(of: i)
                                self.imagesData.remove(at: killImage!)
                                }
                            
                            }
                            self.collectionView?.reloadData()
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
       
        let imageview:UIImageView = UIImageView(frame: CGRect(x: 1, y: 1, width: 134, height: 135))
        if self.imagesData.count > 0 {
            
            let image = self.imagesData[indexPath.row]
            imageview.image = image
            cell.contentView.addSubview(imageview)
        }
        return cell
    }
    
    // MARK: OBJC functions
    
    @objc func reloadCollectionImages() {
        
        self.imagesData = []
        self.photos = []
        downloadingImage.getImageWithNew(lat: lat, long: long, controller: dataController) { (images) in
            let photo = Photo(context: self.dataController.viewContext)
            photo.imageData = images
            try? self.dataController.viewContext.save()
            self.imagesData.append(UIImage(data: images)!)
            self.collectionView?.reloadData()
        }
        
    }
    @objc func deletePhotos(sender: Photo) {
     
        let deletedImage = sender
        dataController.viewContext.delete(deletedImage)
        try? dataController.viewContext.save()
        
 
            
        }
    
    
}








