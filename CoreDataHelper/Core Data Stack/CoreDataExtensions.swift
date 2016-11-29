//
//  ManagedObjectHelpers.swift
//  CoreDataHelper
//
//  Created by Chris Wunsch on 17/10/2016.
//  Copyright © 2016 Minty Water Ltd. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    /// Delete more than one managed object quickly and easily.
    ///
    /// - Parameter objects: the objects to delete
    func delete(allObjects objects : [NSManagedObject]) {
        for object in objects {
            delete(object)
        }
    }
}

extension NSManagedObject {
    
    /// Insert a new record into the database. This will return the newly created managed object
    ///
    /// - Parameter context: the context in which to insert the record
    /// - Returns: a new NSManagedObject
    class func insertNewInstance(withContext context : NSManagedObjectContext) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: self.className, into: context)
    }
    
    /// The entity description for the object in the database
    ///
    /// - Parameter context: the context in whch the entity exists
    /// - Returns: the NSEntityDescription for the object
    class func entityDescription(withContext context : NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: self.className, in: context)!
    }
    
    /// Create a fetch request with the provided context
    ///
    /// - Parameter context: the context for which the fetch request should be created
    /// - Returns: the NSFetchRequest
    class func fetchRequest(withContext context : NSManagedObjectContext) -> NSFetchRequest<NSManagedObject> {
        
        let request : NSFetchRequest<NSManagedObject> = NSFetchRequest()
        request.entity = entityDescription(withContext: context)
        
        return request
    }
    
    /// Create a fetch request with a batch size and an offset.
    ///
    /// - Parameters:
    ///   - context: the context for which the fetch request should be created
    ///   - batch: the size of the batch of objects to fetch
    ///   - offsetSize: the offset to use
    /// - Returns: the NSFetchRequest
    class func fetchRequest(withContext context : NSManagedObjectContext, batchSize batch : Int, offset offsetSize : Int ) -> NSFetchRequest<NSManagedObject> {
        
        let request =  fetchRequest(withContext: context)
        request.fetchBatchSize = batch
        
        if offsetSize > 0 {
            request.fetchOffset = offsetSize
        }
        
        return request;
        
    }
    
    /// Fetch a single object from the database using a predciate. Throws if more than one object is found with that predicate.
    ///
    /// - Parameters:
    ///   - predicate: the predicate to use in the fetch
    ///   - managedContext: the context in which to execute the fetch request
    ///   - pendingChanges: whether to include pending changes
    /// - Returns: a new NSManagedObject - nil if no object was found
    /// - Throws: throws is the fetch request fails or if more than one object is found
    class func fetchSingleObject(withPredicate predicate : NSPredicate, context managedContext : NSManagedObjectContext, includesPendingChanges pendingChanges : Bool) throws -> NSManagedObject? {
        
        let request = fetchRequest(withContext: managedContext)
        request.includesPendingChanges = pendingChanges
        request.predicate = predicate
        request.sortDescriptors = []
    
        var results : [NSManagedObject]
        
        do {
            results = try managedContext.fetch(request)
        } catch {
            print("error executing request: \(error.localizedDescription)")
            throw error
        }
        
        if results.count > 0 {
            guard results.count == 1 else {
                let error = NSError(domain: "CoreDataStackDomain", code: 9000, userInfo: ["Reason" : "Fetch single object with predicate found more than one. This is considered fatal as we now do not know which one should be returned..."])
                throw error
            }
            
            return results.first!
        }
        
        return nil
    }
    
    /// Fetch all the objects that match the predicate and sort them using the sort descriptor.
    ///
    /// - Parameters:
    ///   - predicate: the predicate to use in the fetch
    ///   - sortDescriptors: the sort desciptor by which to sort the fetched objects
    ///   - managedContext: the context in which to execute the fetch request
    /// - Returns: an array of NSManagedObjects
    /// - Throws: Throws errors relating to executing the fetch request
    class func fetchObjects(withPredicate predicate : NSPredicate?, descriptors sortDescriptors : [NSSortDescriptor], context managedContext : NSManagedObjectContext) throws -> [NSManagedObject] {
        
        let request = fetchRequest(withContext: managedContext)
        request.sortDescriptors = sortDescriptors
        
        if predicate != nil {
            request.predicate = predicate;
        }
        
        var results = [NSManagedObject]()
        
        do {
            results = try managedContext.fetch(request)
        } catch {
            print("error executing request: \(error.localizedDescription)")
            throw error
        }
        
        return results
    }
    
    /// Fetch all the objects that match the predicate and sort them using the descriptor. This API has an extra parameter to limit the number of objects returned as well as to set the offset.
    ///
    /// - Parameters:
    ///   - offset: the offset to use in the request
    ///   - requestPredicate: the predicate for the request
    ///   - fetchLimit: the maximum nunmber of objects to return
    ///   - sortDescriptiors: the sort decriptor to use when sorting the objects
    ///   - managedContext: the context in which to execute the fetch request
    /// - Returns: an array of NSManagedObjects
    /// - Throws: Throws errors relating to executing the fetch request
    class func fetchObjects(withOffset offset : Int, predicate requestPredicate : NSPredicate?, limit fetchLimit : Int, descriptors sortDescriptiors : [NSSortDescriptor], context managedContext : NSManagedObjectContext) throws -> [NSManagedObject] {
        
        let request = fetchRequest(withContext: managedContext)
        request.fetchOffset = offset
        request.fetchLimit = fetchLimit
        request.sortDescriptors = sortDescriptiors
        
        if requestPredicate != nil {
            request.predicate = requestPredicate
        }
        
        var results = [NSManagedObject]()
        
        do {
            results = try managedContext.fetch(request)
        } catch {
            print("error executing request: \(error.localizedDescription)")
            throw error
        }
        
        return results
    }
}
