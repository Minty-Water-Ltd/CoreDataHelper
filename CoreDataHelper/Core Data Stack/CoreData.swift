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

struct CoreDataStackConstants {
    
    static let serialQueueName = "CoreDataStackCompletionBlockQueue"
}

class CoreDataStack: NSObject {
    
    // MARK: Private variables
    
    private var completionBlocks = [String : coreDataSaveCompletion]()
    
    private var mainContext : NSManagedObjectContext?
    
    @available(iOS 10.0, *)
    private lazy var persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataHelperConstants.dataBaseName)
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
    
    private lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator? = {
       
        let applicationDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let storeURL = applicationDocumentsDirectory?.appendingPathComponent(CoreDataHelperConstants.dataBaseName + ".sqlite")
        
        let managedObjectModel = NSManagedObjectModel(byMerging: nil)
        
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true];

        do {
            try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch {
            print("Error creating persistent store \(error)")
            
            if #available(iOS 9.0, *) {
                do {
                    try storeCoordinator.destroyPersistentStore(at: storeURL!, ofType: NSSQLiteStoreType, options: options)
                    try FileManager.default.removeItem(at: storeURL!)
                } catch {
                    print("Error destroying persistent store \(error)")
                    
                    return nil
                }
            }
            
            return nil
        }
        
        return storeCoordinator
    }()
    
    private let serialQueue = DispatchQueue(label: CoreDataStackConstants.serialQueueName)
    
    /// The singleton used to access the contexts and apis. This should be the only access point to this stack. Creating a new instance of the CoreDataStack may lead to unexpected behaviour.
    class var defaultStack: CoreDataStack {
        struct Singleton {
            static let instance = CoreDataStack()
        }
        
        return Singleton.instance
    }
    
    
    /// Private init method, used interally to setup any vars etc...
    ///
    /// - returns: a new instance of CoreDataStack
    private override init() {
        super.init()
        
    }
    
    // MARK: - Managed Object Contexts
    
    /// Returns the persistentContainers viewContext. This context should ONLY be used for rednering data to the UI. Use this in fetchedResultsControllers etc... Updated are automatically merged when using the 'privateQueueContext' and the internal 'saveContext' api.
    ///
    /// - returns: the main NSManagedObjectContext
    func mainQueueContext() -> NSManagedObjectContext {
        
        if mainContext != nil {
            return mainContext!
        }
        
        if #available(iOS 10.0, *) {
            mainContext = persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        
        return mainContext!
    }
    
    /// A new private context, this has the 'mainQueueContext' set as it's parent and the concurrencyType set to privateQueueConcurrencyType
    ///
    /// - returns: a new NSManagedObjectContext
    func privateQueueContext() -> NSManagedObjectContext {
        
        var newContext : NSManagedObjectContext?
        
        if #available(iOS 10.0, *) {
            newContext = persistentContainer.newBackgroundContext()
        } else {
            // Fallback on earlier versions
            newContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            newContext?.parent = mainContext
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(invokeCompletionBlocks(_:)), name: .NSManagedObjectContextDidSave, object: newContext)
        
        return newContext!
    }

    
    // MARk: Saving contexts:
    
    /// Call this and supply the context that you wish to save. A completion block can be supplied if you are peforming a long running backround task. This will throw if there is an error saving OR if you attempt to save any changes to the main context.
    ///
    /// - parameter context: the context who's changes should be save - hasChanges is checked internally
    /// - parameter block:   the completion block that should be invoked once the context has saved and it's changes merged into the main context
    ///
    /// - throws: NSError relating to context.save() or if attempting to save the main context
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
    
    // MARK: Completion block execution:
    
    
    /// This is responsible for invoking the completion block provided when the context was saved. This is executed on the back of the 'NSManagedObjectContextDidSave' notification.
    ///
    /// - parameter notification: the notification that contains the managedObjectContext that was just saved
    internal func invokeCompletionBlocks(_ notification : Notification) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            
            let mainContext = self.mainQueueContext()
            
            // Merge the changes from the recently saved private queue into the main context:
            mainContext.performSelector(onMainThread: #selector(mainContext.mergeChanges(fromContextDidSave:)), with: notification, waitUntilDone: true)
            
            // Save the recently merged changes:
            mainContext.performSelector(onMainThread: #selector(mainContext.save), with: notification, waitUntilDone: true)
            
            //Get the managedObject from the notification:
            let managedObject = notification.object as! NSManagedObjectContext
            
            //Synchronise access to the queue:
            self.serialQueue.sync() {
                
                let completionBlock = self.completionBlocks[managedObject.description]
                
                if completionBlock != nil {
                    DispatchQueue.main.async {
                        completionBlock!!(managedObject)
                    }
                    
                    self.completionBlocks[managedObject.description] = nil
                }
            }
        }
    }
}
