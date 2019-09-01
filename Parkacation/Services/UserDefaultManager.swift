//
//  UserDefaultManager.swift
//  Parkacation
//
//  Created by Darin Williams on 8/30/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation


struct Constants {
    struct Authentication {
        static let userIsLoggedIn = "UserIsLoggedIn"
    }
    
    
    private init() {
        
    }
    
    
}


class UserDefaultManager {
    
    static let shared = UserDefaultManager()
    
    
    private init() {}
    
    
    var userLoggedIn: Bool {
        
        get {
            
            return UserDefaults.standard.bool(forKey: Constants.Authentication.userIsLoggedIn)
            
        }
        
        set {
            
            return UserDefaults.standard.set(newValue, forKey: Constants.Authentication.userIsLoggedIn)
        }
    }
    
}
