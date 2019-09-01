//
//  FireBaseApi.swift
//  Parkacation
//
//  Created by Darin Williams on 8/30/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

struct FireBaseApi {
    
    static let shared = FireBaseApi()
    
    private init() {
        
    }
    
    
    private let dbRef = Database.database().reference(withPath: "data")
    
    private let storageRef = Storage.storage().reference()
    
    
    private var flagModel = [FlagsModel]()
    
    
    var userID: String {
        
        get {
            
            return Auth.auth().currentUser!.uid
        }
    }
    
    func signUp(email: String, password: String, completionHandler: @escaping (Error?) -> Void) {
        
        let userData: [String: Any] =  ["name":uname]
    
        Auth.auth().createUser(withEmail: email, password: password) { (results, error) in
            
            if let err = error {
                debugPrint("Authentication Error")
                completionHandler(err)
            } else {
            
            guard let uid = results?.user.uid else {
                return
            }
                
            self.dbRef.child("users /\(uid)").setValue(userData)
            UserDefaultManager.shared.userLoggedIn = false
            debugPrint("Succesfully Logged in")
            completionHandler(nil)
            
        }
    
    }
    
}
    
    
    func logOut(completionHandler: (Error?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            UserDefaultManager.shared.userLoggedIn = false
            completionHandler(nil)
            debugPrint("Successfully logged out")
        } catch let error {
            debugPrint("FireBaseApi: \(error.localizedDescription)")
            completionHandler(error)
        }
        
        
    }
    
 
    
    func logIn(email: String, password: String, completionHandler: @escaping (Error?) -> Void) {
        
        
        Auth.auth().signIn(withEmail: email, link: password) { (user, error) in
            if let err = error {
                
                completionHandler(err)
                
                debugPrint("Error: loginIn \(err.localizedDescription))")
            } else {
                
                guard let uid = user?.user.uid else {
                
                    return
            }
                debugPrint("Successfully Login")
                UserDefaultManager.shared.userLoggedIn = true
                completionHandler(nil)
        }
        
        
        
    }
  
    
}
//
// func loadFromDatabase() -> [FlagsModel]{
//    
//    //MARK Iterate over items FROM DATABASE
//    var dataModel:[FlagsModel] = []
//    
//        self.dbRef.observe(.value, with: {snapshot in
//            
//         
//            for item in snapshot.children {
//                
//                if let snapshot = item as? DataSnapshot,
//                    let flgItem =  FlagsModel(snapshot: snapshot){
//                    dataModel.append(flgItem)
//                }
//                debugPrint("LOADFROM DATABASE: datamodel count.. \(dataModel.count)")
//                
//            }
//      
//        })
//    
//      return  dataModel
//    }
//    
    
    
}
