//
//  ImagesServices.swift
//  Parkacation
//
//  Created by Darin Williams on 8/24/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ImageServices {
    
    
    
    static func downLoadImage(forURL  url: URL, completion: @escaping(_ image:UIImage?)->()) {
    
      var usFlagModel = [FlagsModel]()

        if let imageURL = usFlagModel.flagImage as? String{
        if imageURL.hasPrefix("gs://") {
            Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) {(data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    sfCell.photoImage.image = UIImage.init(data: data!)
                    sfCell.setNeedsLayout()
                }
            }
        } else if let URL = URL(string: imageURL), let data = try? Data(contentsOf: URL) {
            sfCell.photoImage.image = UIImage.init(data: data)
        }
    ]
            
}
    
}
