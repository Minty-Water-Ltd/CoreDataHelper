//
//  ManagedObjectHelpers.swift
//  CoreDataHelper
//
//  Created by Chris Wunsch on 17/10/2016.
//  Copyright © 2016 Minty Water Ltd. All rights reserved.
//

import Foundation
import CoreData

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

extension NSManagedObjectContext {
    func deleteAllObjects(_ objects : [NSManagedObject]) throws {
        for object in objects {
            delete(object)
        }
    }
}

extension NSManagedObject {
    
    class func entityDescriptionWithContext(_ context : NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: self.className, in: context)!
    }
    
    class func fetchRequestWithContext(_ context : NSManagedObjectContext) -> NSFetchRequest<NSManagedObject> {
        
        let request : NSFetchRequest<NSManagedObject> = NSFetchRequest()
        request.entity = entityDescriptionWithContext(context)
        
        return request
    }
    
    class func fetchRequestWithContext(_ context : NSManagedObjectContext, batchSize batch : Int, offset offsetSize : Int ) -> NSFetchRequest<NSManagedObject> {
        
        let request = fetchRequestWithContext(context)
        request.fetchBatchSize = batch
        
        if offsetSize > 0 {
            request.fetchOffset = offsetSize
        }
        
        return request;
        
    }
    
    class func fetchSingleObjectWithPredicate(_ predicate : NSPredicate, context managedContext : NSManagedObjectContext, includesPendingChanges pendingChanges : Bool) throws -> NSManagedObject? {
        
        let request = fetchRequestWithContext(managedContext)
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
    
    class func fetchObjectsWithPredicate(_ predicate : NSPredicate?, descriptors sortDescriptors : [NSSortDescriptor], context managedContext : NSManagedObjectContext) throws -> [NSManagedObject] {
        
        let request = fetchRequestWithContext(managedContext)
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
    
    class func fetchObjectsWithOffset(_ offset : Int, predicate requestPredicate : NSPredicate?, limit fetchLimit : Int, descriptors sortDescriptiors : [NSSortDescriptor], context managedContext : NSManagedObjectContext) throws -> [NSManagedObject] {
        
        let request = fetchRequestWithContext(managedContext)
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
