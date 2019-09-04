//
//  ViewController+Extension.swift
//  Parkacation
//
//  Created by Darin Williams on 9/1/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FBSDKLoginKit


extension UIViewController {
    func showInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        performUIUpdatesOnMain {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    @objc func handleSignOut(){
        
        UserDefaults.standard.set(false, forKey: "userIsLoggedIn")
        UserDefaults.standard.synchronize()
        
        //LOGOUT OF Facebook
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logOut()
        
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let lgView  = mainStoryBoard.instantiateViewController(withIdentifier:"LoginViewController") as! LoginViewController
        
        
        present(lgView, animated: false, completion: nil)
    }
    
    @objc func configureDatabase() -> DatabaseReference {
        //MARK CALL FLAG API
        // Do any additional setup after loading the view.
        return Database.database().reference(withPath: "data")
        
    }
    
    @objc func configureStorage() -> StorageReference {
        return Storage.storage().reference()
        
    }
    

    
}
