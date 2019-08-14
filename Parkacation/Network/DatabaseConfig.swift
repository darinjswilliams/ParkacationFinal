//
//  DatabaseConfig.swift
//  Parkacation
//
//  Created by Darin Williams on 8/1/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import Firebase


class DatabaseConfig {
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    
    func configureDatabase() {
          ref = Database.database().reference()
    }
    
    
    func configureStorage(){
         storageRef = Storage.storage().reference()
        
    }
    
    
}
