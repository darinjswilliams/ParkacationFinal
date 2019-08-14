//
//  AllStates.swift
//  Parkacation
//
//  Created by Darin Williams on 8/1/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation


struct USFlags {
    
    let abbrName, fullName,  flagImage: String
   
   static let AbbrNameKey = "AbbrNameKey"
   static let FlagImageKey = "FlagImageKey"
   static let FullNameKey = "FullNameKey"
    
    
    init(dictionary: [String : String]) {
        
        self.abbrName = dictionary[USFlags.AbbrNameKey]!
        self.fullName = dictionary[USFlags.FullNameKey]!
        self.flagImage = dictionary[USFlags.FlagImageKey]!
    }
    
    
}

extension USFlags {
    
    // Generate an array full of all of the villains in
    static var allFlags: [USFlags] {
        
        var usFlagsArray = [USFlags]()
        
        for dt in USFlags.localFlagData() {
            usFlagsArray.append(USFlags(dictionary: dt))
        }
        
        return usFlagsArray
    }
    
    static func localFlagData() -> [[String : String]] {
        return [
            [USFlags.AbbrNameKey : "TX",  USFlags.FullNameKey : "Texas",  USFlags.FlagImageKey : "tx"],
            [USFlags.AbbrNameKey  : "AZ", USFlags.FullNameKey : "Arizona",  USFlags.FlagImageKey : "az"],
            [USFlags.AbbrNameKey  : "OK", USFlags.FullNameKey : "Oklahoma",  USFlags.FlagImageKey : "ok"],
            [USFlags.AbbrNameKey  : "NY", USFlags.FullNameKey : "New York",  USFlags.FlagImageKey : "ny"],
            [USFlags.AbbrNameKey : "NJ",  USFlags.FullNameKey : "New Jersey",  USFlags.FlagImageKey : "nj"],
            [USFlags.AbbrNameKey  : "CA", USFlags.FullNameKey : "California",  USFlags.FlagImageKey : "ca"],
            [USFlags.AbbrNameKey : "IL",  USFlags.FullNameKey : "Illinois",  USFlags.FlagImageKey : "il"],
            [USFlags.AbbrNameKey  : "WA", USFlags.FullNameKey : "Washington",  USFlags.FlagImageKey : "wa"],
            [USFlags.AbbrNameKey  : "LA", USFlags.FullNameKey : "Louisanna",  USFlags.FlagImageKey : "la"],
            [USFlags.AbbrNameKey  : "MS", USFlags.FullNameKey : "Mississippi",  USFlags.FlagImageKey : "ms"],
            [USFlags.AbbrNameKey  : "AL", USFlags.FullNameKey : "Alabama",  USFlags.FlagImageKey : "al"],
            [USFlags.AbbrNameKey  : "FL", USFlags.FullNameKey : "Florida",  USFlags.FlagImageKey : "fl"],
            [USFlags.AbbrNameKey  : "GA", USFlags.FullNameKey : "Georgia",  USFlags.FlagImageKey : "ga"]
        ]
    }
}

