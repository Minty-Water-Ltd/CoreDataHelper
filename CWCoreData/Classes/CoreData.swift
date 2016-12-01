//
//  CWCoreData.swift
//  CoreDataHelper
//
//  Created by Chris Wunsch on 16/10/2016.
//  Copyright © 2016 Minty Water Ltd. All rights reserved.
//

import Foundation
import CoreData

public typealias coreDataSaveCompletion = ((_ context : NSManagedObjectContext) -> Void)?

struct CoreDataStackConstants {
    
    static let serialQueueName = "CoreDataStackCompletionBlockQueue"
    
}

public class CoreDataStack : NSObject {
    
    // MARK: Variables
    private var completionBlocks = [String : ((SaveResult) -> Void)?]()
    
    public var dataBaseName : String?
    
    public lazy var mainQueueContext : NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            return self.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
            return mainContext
        }
    }()
    
    @available(iOS 10.0, *)
    private lazy var persistentContainer : NSPersistentContainer = {
        assert(self.dataBaseName != nil, "You must set the database name!!")
        
        let container = NSPersistentContainer(name: self.dataBaseName!)
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
                exit(0)
            }
        })
        return container
    }()

    //The documents directory:
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    //The managed object model:
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
        return managedObjectModel!
    }()

    //The persistent store coordinator:
    private lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator? = {
        
        assert(self.dataBaseName != nil, "You must set the database name!!")
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory.appendingPathComponent(self.dataBaseName! + ".sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption : true,
                       NSInferMappingModelAutomaticallyOption : true];
        
        do {
            // If your looking for any kind of migration then here is the time to pass it to the options
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch let  error as NSError {
            print("Error creating persistent store \(error)")
            
            if #available(iOS 9.0, *) {
                do {
                    try coordinator.destroyPersistentStore(at: url!, ofType: NSSQLiteStoreType, options: options)
                    try FileManager.default.removeItem(at: url!)
                } catch {
                    print("Error destroying persistent store \(error)")
                    
                    return nil
                }
            }
            
            return nil
        }
        
        return coordinator
    }()

    //The serial queue used to execute the completion blocks:
    private let serialQueue = DispatchQueue(label: CoreDataStackConstants.serialQueueName)
    
    /// The singleton used to access the contexts and APIs.
    /// This should be the only access point to this stack.
    /// Creating a new instance of the CoreDataStack may lead to unexpected behaviour.
    public class var defaultStack: CoreDataStack {
        struct Singleton {
            static let instance = CoreDataStack()
        }
        
        return Singleton.instance
    }
    
    /// Private init method, used internally to setup any vars etc...
    ///
    /// - returns: a new instance of CoreDataStack
    private override init() {
        super.init()
    }
    
    // MARK: - Managed Object Contexts
    
    /// A new private context, this has the 'mainQueueContext' set as it's parent and the concurrencyType set to privateQueueConcurrencyType
    ///
    /// - returns: a new NSManagedObjectContext
    public class func privateQueueContext(withMergePolicy mergePolicy : NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) -> NSManagedObjectContext {
        
        var newContext : NSManagedObjectContext?
        
        if #available(iOS 10.0, *) {
            newContext = CoreDataStack.defaultStack.persistentContainer.newBackgroundContext()
        } else {
            // Fallback on earlier versions
            newContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            newContext?.parent = CoreDataStack.defaultStack.mainQueueContext
        }
        
        newContext?.mergePolicy = NSMergePolicy(merge: mergePolicy)

        //Add the did save context notification to the new context:
        NotificationCenter.default.addObserver(CoreDataStack.defaultStack, selector: #selector(invokeCompletionBlocks(_:)), name: .NSManagedObjectContextDidSave, object: newContext)
        
        return newContext!
    }
    
    // MARk: Saving contexts:
    
    /// Call this and supply the context that you wish to save. A completion block can be supplied if you are peforming a long running backround task. This will throw if there is an error saving OR if you attempt to save any changes to the main context.
    ///
    /// - parameter context: the context who's changes should be save - hasChanges is checked internally
    /// - parameter block:   the completion block that should be invoked once the context has saved and it's changes merged into the main context
    ///
    /// - throws: NSError relating to context.save() or if attempting to save the main context
    public func saveContext(_ context  : NSManagedObjectContext, performAndWait : Bool = true, completionHandler completionBlock : ((SaveResult) -> Void)? = nil) {
        
        guard context != mainQueueContext else {
            let error = NSError(domain: "CoreDataStackDomain", code: 9001, userInfo: ["Reason" : "Failed becuase you are trying to save changes to the main context. You can only save changes to the private contexts. Only use the main context to present data in the UI."])
            completionBlock?(.failure(error))
            
            return
        }
        
        guard context.hasChanges else {
            let error = NSError(domain: "CoreDataStackDomain", code: 9001, userInfo: ["Reason" : "The contesxt did not have any changes..."])
            if completionBlock != nil {
                completionBlock?(.failure(error))
            }
            return
        }
        
        let block = {
            do {
                if completionBlock != nil {
                    self.completionBlocks[context.description] = completionBlock
                }
                try context.save()
            } catch {
                let newError = error as NSError
                print("Unresolved error \(newError), \(newError.userInfo)")
                if completionBlock != nil {
                    self.completionBlocks[context.description] = nil
                }
                completionBlock?(.failure(error as NSError))
            }
        }
        
        performAndWait ? context.performAndWait(block) : context.perform(block)
    }
    
    // MARK: Completion block execution:
    
    /// This is responsible for invoking the completion block provided when the context was saved. This is executed on the back of the 'NSManagedObjectContextDidSave' notification.
    ///
    /// - parameter notification: the notification that contains the managedObjectContext that was just saved
    @objc fileprivate func invokeCompletionBlocks(_ notification : Notification) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {

            //Get the main context:
            let mainContext = self.mainQueueContext
            
            // Merge the changes from the recently saved private queue into the main context:
            mainContext.performSelector(onMainThread: #selector(mainContext.mergeChanges(fromContextDidSave:)), with: notification, waitUntilDone: true)
            
            // Save the recently merged changes:
            mainContext.performSelector(onMainThread: #selector(mainContext.save), with: notification, waitUntilDone: true)
            
            //Get the managedObject from the notification:
            let managedObject = notification.object as! NSManagedObjectContext
            
            //Synchronise access to the queue:
            self.serialQueue.sync() {

                //Get the completion block:
                let completionBlock = self.completionBlocks[managedObject.description]

                //If there is one, then execute it:
                if completionBlock != nil {
                    completionBlock!!(.success)
                    self.completionBlocks[managedObject.description] = nil
                }
            }
        }
    }
}
