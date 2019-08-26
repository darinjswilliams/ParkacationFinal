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
    
    var dbRef: DatabaseReference!
    var storageRef: StorageReference!
    var dataModel:[FlagsModel] = []
    
    
    fileprivate func configureDatabase() -> DatabaseReference {
          return Database.database().reference()
    }
    
    
    fileprivate func configureStorage(){
         storageRef = Storage.storage().reference()
        
    }
    
    //Mark From Firebase
    func loadFromDatabase() -> [FlagsModel]{
    
        dbRef = configureDatabase()
     
        dbRef.observe(.value, with: {snapshot in
            
            //MARK Iterate over items FROM DATABASE
           
            for item in snapshot.children {
                
                if let snapshot = item as? DataSnapshot,
                    let flagModel =  FlagsModel(snapshot: snapshot){
                    self.dataModel.append(flagModel)
                }
                debugPrint("LOADFROM DATABASE: datamodel count.. \(self.dataModel.count)")
                
            }
     
        })
    
        //MARK LOAD DATA INTO ARRAY AND RELOAD TABLE
        return dataModel
        
        LoadingViewActivity.hide()
    }
    
}
