//
//  StateFlag.swift
//  Parkacation
//
//  Created by Darin Williams on 7/28/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import UIKit

struct StateFlag {
    
    let stateShortName: String
    let stateLongName: String
    let stateFlagImageName: String
    
    static let abbrStateKey = "StateAbrrKey"
    static let fullNameStateKey = "StateFullNameKey"
    static let stateFlagImageKey = "StateFlagImageKey"
    
    
    init(dictionary: [String : String]){
        
        self.stateShortName = dictionary[StateFlag.abbrStateKey]!
        self.stateLongName = dictionary[StateFlag.fullNameStateKey]!
        self.stateFlagImageName = dictionary[StateFlag.stateFlagImageKey]!
        
        
    }

}

extension StateFlag {
    
    
    static var allStates : [StateFlag] {
        
        
        var stateFlagArray = [StateFlag]()
        
        for dt in StateFlag.localStateFlag(){
            stateFlagArray.append(StateFlag(dictionary: dt))
            debugPrint(dt)
        }

        
        return stateFlagArray
    }
    
    
    static func localStateFlag() -> [[String : String]] {
        
        
       let emptyDic: [[String:String]] = [[:]]
        
        for(key, value ) in States.StateArray {
        
     return [
              [StateFlag.abbrStateKey: key, StateFlag.fullNameStateKey: value,
                    StateFlag.stateFlagImageKey : key.lowercased()]
           ]
       }
        
        return emptyDic
    }
    
}
