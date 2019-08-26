//
//  DataController.swift
//  VirturalTouristUdacity
//
//  Created by Darin Williams on 6/8/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import CoreData


class DataController {
    
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
//
//    var backgroundContext:NSManagedObjectContext!
    
    
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
        
        //MARK SETUP MERGE POLICIES SO APP WILL NOT CRASH
//        viewContext.automaticallyMergesChangesFromParent = true
//        backgroundContext.automaticallyMergesChangesFromParent = true
//
//
//        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
//
//
//        viewContext.mergePolicy =  NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
//            self.configContext()
            completion?()
        }
    }
    
    
//    func configContext() {
//
//        backgroundContext = persistentContainer.newBackgroundContext()
//
//    }
    
}
