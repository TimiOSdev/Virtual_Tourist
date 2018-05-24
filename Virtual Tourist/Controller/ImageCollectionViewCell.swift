//
//  ImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by sudo on 5/24/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    var image: UIImage? {
        didSet {
            DispatchQueue.main.async {
                //relaod the cell
            }
        }
    }
    
    
}
