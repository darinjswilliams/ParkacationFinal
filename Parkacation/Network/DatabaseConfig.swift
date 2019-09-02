//
//  DatabaseConfig.swift
//  Parkacation
//
//  Created by Darin Williams on 8/1/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class DatabaseConfig {

    static let shared = DatabaseConfig()

    private init() { }
    
    func configureDatabase() -> DatabaseReference {
          return Database.database().reference(withPath: "data")
    }
    
    
    func configureStorage() -> StorageReference{
         return Storage.storage().reference()
        
    }
    
    //Mark From Firebase
    func loadFromDatabase() -> [FlagsModel]{
    
        let dbRef = configureDatabase()
        var dataModel:[FlagsModel] = []
     
        dbRef.observe(.value, with: {snapshot in
            
            //MARK Iterate over items FROM DATABASE
           
            for item in snapshot.children {
                
                if let snapshot = item as? DataSnapshot,
                    let flagModel =  FlagsModel(snapshot: snapshot){
                    dataModel.append(flagModel)
                }
                debugPrint("LOADFROM DATABASE: datamodel count.. \(dataModel.count)")
                
            }
     
        })
    
        //MARK LOAD DATA INTO ARRAY AND RELOAD TABLE
        return dataModel
  
    }
    
 
}
