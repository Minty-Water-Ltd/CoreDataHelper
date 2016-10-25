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
    func delete(allObjects objects : [NSManagedObject]) throws {
        for object in objects {
            delete(object)
        }
    }
}

extension NSManagedObject {
    
    class func insertNewInstance(withContext context : NSManagedObjectContext) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: self.className, into: context)
    }
    
    class func entityDescription(withContext context : NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: self.className, in: context)!
    }
    
    class func fetchRequest(withContext context : NSManagedObjectContext) -> NSFetchRequest<NSManagedObject> {
        
        let request : NSFetchRequest<NSManagedObject> = NSFetchRequest()
        request.entity = entityDescription(withContext: context)
        
        return request
    }
    
    class func fetchRequest(withContext context : NSManagedObjectContext, batchSize batch : Int, offset offsetSize : Int ) -> NSFetchRequest<NSManagedObject> {
        
        let request =  fetchRequest(withContext: context)
        request.fetchBatchSize = batch
        
        if offsetSize > 0 {
            request.fetchOffset = offsetSize
        }
        
        return request;
        
    }
    
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


