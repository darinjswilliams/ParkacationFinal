//
//  EndPoints.swift
//  Parkacation
//
//  Created by Darin Williams on 8/4/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation


enum EndPoints {
    

    case apiKeyNationalParkService
    case getParks(String)
    case parkBaseService
    case getCoordinates(String)

    
    
    var stringValue: String {
        switch self {
            
        case .getParks(let stateAbbrName): return EndPoints.parkBaseService.stringValue + "/parks?stateCode=\(stateAbbrName)"
            
        case .apiKeyNationalParkService: return AuthenticationUtils.parkApiKey
            
        case .parkBaseService: return "https://developer.nps.gov/api/v1/"
            
        case .getCoordinates(let parkName): return "https://api.opencagedata.com/geocode/v1/json?q=\(parkName)&key=d37a47fa1f1c4ee5b4a387ba14cd028e"
            
        }
    }
    
    var url: URL {
        return URL(string: stringValue)!
    }
}

