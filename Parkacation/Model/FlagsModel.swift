//
//  FlagsModel.swift
//  Parkacation
//
//  Created by Darin Williams on 8/11/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import Firebase

struct FlagsModel {
    
    let dbRef: DatabaseReference?
    let key: String
    let abbrName:String
    let fullName:String
    let flagImage: String
    
    init(abbrName: String, fullName: String, flagImage: String, key: String = ""){
        self.dbRef = nil
        self.key = key
        self.abbrName = abbrName
        self.fullName = fullName
        self.flagImage = flagImage
    }
    
    init?(snapshot: DataSnapshot){
        guard
            let value = snapshot.value as? [String: AnyObject],
            let abbrName = value["abbrname"] as? String,
            let fullName = value["fullname"] as? String,
            let flagImage = value["flagimage"] as? String else {
                return nil
        }
        
        self.dbRef = snapshot.ref
        self.key = snapshot.key
        self.abbrName = abbrName
        self.fullName = fullName
        self.flagImage = flagImage
    }
    
    func toAnyObject() -> Any {
        return [
            "abbrname": abbrName,
            "fullname": fullName,
            "flagimage": flagImage
        ]
    }
}
