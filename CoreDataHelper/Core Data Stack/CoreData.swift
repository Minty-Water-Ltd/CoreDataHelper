//
//  CWCoreData.swift
//  CoreDataHelper
//
//  Created by Chris Wunsch on 16/10/2016.
//  Copyright © 2016 Minty Water Ltd. All rights reserved.
//

import Foundation
import CoreData

typealias coreDataSaveCompletion = ((_ context : NSManagedObjectContext) -> Void)?

class CoreDataStack: NSObject {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataHelper")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    
    var completionBlocks = [String : coreDataSaveCompletion]()
    
    class var defaultStack: CoreDataStack {
        struct Singleton {
            static let instance = CoreDataStack()
        }
        
        return Singleton.instance
    }
    
    
    override init() {
    
        super.init()
        
    }
    
    
    // MARK: - Public contexts:
    
    func mainQueueContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func privateQueueContext() -> NSManagedObjectContext {
        let newContext = persistentContainer.newBackgroundContext()
        NotificationCenter.default.addObserver(self, selector: #selector(invokeCompletionBlocks(_:)), name: .NSManagedObjectContextDidSave, object: newContext)
        
        return newContext
    }

    
    // MARk: Saving contexts:
    
    func saveContext(_ context  : NSManagedObjectContext, completionHandler block : coreDataSaveCompletion?) throws {
        
        guard context != mainQueueContext() else {
            let error = NSError(domain: "CoreDataStackDomain", code: 9001, userInfo: ["Reason" : "Failed becuase you are trying to save changes to the main context. You can only save changes to the private contexts. Only use the main context to present data in the UI."])
            throw error
        }
        
        if context.hasChanges {
            do {
                if block != nil {
                    completionBlocks[context.description] = block
                }
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                if block != nil {
                    completionBlocks[context.description] = nil
                }
                throw nserror
            }
        }   
    }
    
    func invokeCompletionBlocks(_ notification : Notification) {
        
        let mainContext = mainQueueContext()
        
        // Merge the changes from the recently saved private queue into the main context:
        mainContext.performSelector(onMainThread: #selector(mainContext.mergeChanges(fromContextDidSave:)), with: notification, waitUntilDone: true)
        
        // Save the recently merged changes:
        mainContext.performSelector(onMainThread: #selector(mainContext.save), with: notification, waitUntilDone: true)
        
        
        //Get the managedObject from the notification:
        let managedObject = notification.object as! NSManagedObjectContext
        
        let completionBlock = completionBlocks[managedObject.description]
        
        if completionBlock != nil {
            completionBlock!!(managedObject)
        }
        
        completionBlocks[managedObject.description] = nil
    }    
}
