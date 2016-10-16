//
//  CWCoreData.swift
//  CoreDataHelper
//
//  Created by Chris Wunsch on 16/10/2016.
//  Copyright © 2016 Minty Water Ltd. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack: NSObject {
    
    var mainContext : NSManagedObjectContext?
    
    let persistentStoreCoordinator = PersistentStoreManager().initialisePersistentStore()
    
    var completionBlocks : NSMutableArray?
    
    
    override init() {
        
    }
    
    
    
}


class PersistentStoreManager : NSObject {
    
    override init() {
        
        super.init()
        
    }
    
    
    func initialisePersistentStore() -> NSPersistentStoreCoordinator {
        
        let applicationsBundles = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        
        let storeURL = applicationsBundles?.appendingPathComponent("CoreDataHelper.sqlite")
        
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
        
        let persistentStore = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
    
        do {
        
            try persistentStore.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
            
        }
        
        catch {
            print("error", error.localizedDescription)
            
            do {
                try persistentStore.destroyPersistentStore(at: storeURL!, ofType: NSSQLiteStoreType, options: options)
                try FileManager.default.removeItem(at: storeURL!)
            }
            catch {
                print("error removing store...", error)
            }
        }

        return persistentStore
    }
    
}
