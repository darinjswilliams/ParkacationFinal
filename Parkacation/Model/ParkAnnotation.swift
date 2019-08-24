//
//  ParkAnnotation.swift
//  Parkacation
//
//  Created by Darin Williams on 8/21/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ParkAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var eta: String?
    var mile: String?
    var image: UIImage?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
