import UIKit
import XCTest
import CWCoreData

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreationOfCoreDataStack() {
        let coreDataStack = CoreDataStack.defaultStack
        
        XCTAssertEqual(coreDataStack, CoreDataStack.defaultStack)
    }
    
//    func testSaveOfObject() {
//        
//        let mainContext = CoreDataStack.defaultStack.mainQueueContext
//        
//        let privateContext = CoreDataStack.privateQueueContext
//        
//        let newEvent = Event(context: privateContext)
//        
//        // If appropriate, configure the new managed object.
//        newEvent.timestamp = NSDate()
//        
//        do {
//            try CoreDataStack.defaultStack.saveContext(privateContext, completionHandler: nil)
//            let objectID = try mainContext.existingObject(with: newEvent.objectID)
//            XCTAssertNotNil(objectID)
//        }
//        catch {
//            XCTFail()
//            print(error)
//        }
//        
//    }
//    
//    func testThrowOnMainContextSave() {
//        
//        let mainContext = CoreDataStack.defaultStack.mainQueueContext
//        
//        let newEvent = Event(context: mainContext)
//        newEvent.timestamp = NSDate()
//        
//        do {
//            try CoreDataStack.defaultStack.saveContext(mainContext, completionHandler: nil)
//        }
//        catch {
//            XCTAssertNotNil(error)
//        }
//    }
//    
//    func testDeleteOfObject() {
//        
//        let asyncExpectation = expectation(description: "Deletion task")
//        
//        let privateContext = CoreDataStack.defaultStack.privateQueueContext
//        
//        let newEvent = Event(context: privateContext)
//        newEvent.timestamp = NSDate()
//        
//        do {
//            try CoreDataStack.defaultStack.saveContext(privateContext, completionHandler: nil)
//            let object = try CoreDataStack.defaultStack.mainQueueContext().existingObject(with: newEvent.objectID)
//            XCTAssertNotNil(object)
//            
//            privateContext.delete(newEvent)
//            
//            try CoreDataStack.defaultStack.saveContext(privateContext, completionHandler: { (savedContext) in
//                do {
//                    
//                    try CoreDataStack.defaultStack.mainQueueContext().existingObject(with: newEvent.objectID)
//                    
//                    XCTFail()
//                    asyncExpectation.fulfill()
//                }
//                catch {
//                    XCTAssertNotNil(error)
//                    asyncExpectation.fulfill()
//                }
//            })
//            
//        }
//        catch {
//            print(error)
//            XCTFail()
//            asyncExpectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error)
//        }
//    }
//    
//    
//    func testFetchSingleObject() {
//        
//        let mainContext = CoreDataStack.defaultStack.mainQueueContext
//        
//        let privateContext = CoreDataStack.privateQueueContext
//        
//        let newEvent = Event(context: privateContext)
//        
//        // If appropriate, configure the new managed object.
//        newEvent.timestamp = NSDate()
//        
//        do {
//            try CoreDataStack.defaultStack.saveContext(privateContext, completionHandler: nil)
//            
//            let predicate = NSPredicate(format: "timestamp = %@", newEvent.timestamp!)
//            
//            let object = try Event.fetchSingleObject(withPredicate: predicate, context: mainContext, includesPendingChanges: true)
//            
//            XCTAssertNotNil(object)
//        }
//        catch {
//            print(error)
//        }
//    }
//    
//    func testFetchAllObjects() {
//        let mainContext = CoreDataStack.defaultStack.mainQueueContext
//        
//        let privateContext = CoreDataStack.privateQueueContext
//        
//        let newEvent = Event(context: privateContext)
//        
//        // If appropriate, configure the new managed object.
//        newEvent.timestamp = NSDate()
//        
//        let newEvent2 = Event(context: privateContext)
//        
//        // If appropriate, configure the new managed object.
//        newEvent2.timestamp = newEvent.timestamp
//        
//        do {
//            try CoreDataStack.defaultStack.saveContext(privateContext, completionHandler: nil)
//            
//            let predicate = NSPredicate(format: "timestamp = %@", newEvent.timestamp!)
//            
//            let object = try Event.fetchObjects(withPredicate: predicate, descriptors: [NSSortDescriptor(key: "timestamp", ascending: true)], context: mainContext)
//            
//            XCTAssertTrue(object.count == 2)
//        }
//        catch {
//            print(error)
//        }
//        
//    }
//    
//    func testFetchAllObjectsWithOffsetWithPredicate() {
//        let mainContext = CoreDataStack.defaultStack.mainQueueContext
//        
//        let privateContext = CoreDataStack.privateQueueContext()
//        
//        let newEvent = Event(context: privateContext)
//        
//        // If appropriate, configure the new managed object.
//        newEvent.timestamp = NSDate()
//        
//        let newEvent2 = Event(context: privateContext)
//        
//        // If appropriate, configure the new managed object.
//        newEvent2.timestamp = newEvent.timestamp
//        
//        do {
//            try CoreDataStack.defaultStack.saveContext(privateContext, completionHandler: nil)
//            
//            let predicate = NSPredicate(format: "timestamp = %@", newEvent.timestamp!)
//            
//            let object = try Event.fetchObjects(withOffset: 1, predicate: predicate, limit: 10, descriptors: [NSSortDescriptor(key: "timestamp", ascending: true)], context: mainContext)
//            
//            XCTAssertTrue(object.count == 1)
//        }
//        catch {
//            print(error)
//        }
//    }
//    
//    func testFetchAllObjectsWithOffset() {
//        
//        let mainContext = CoreDataStack.defaultStack.mainQueueContext
//        
//        let privateContext = CoreDataStack.privateQueueContext
//        
//        let newEvent = Event(context: privateContext)
//        
//        // If appropriate, configure the new managed object.
//        newEvent.timestamp = NSDate()
//        
//        let newEvent2 = Event(context: privateContext)
//        
//        // If appropriate, configure the new managed object.
//        newEvent2.timestamp = newEvent.timestamp
//        
//        do {
//            try CoreDataStack.defaultStack.saveContext(privateContext, completionHandler: nil)
//            
//            let object = try Event.fetchObjects(withOffset: 0, predicate: nil, limit: 1, descriptors: [NSSortDescriptor(key: "timestamp", ascending: true)], context: mainContext)
//            
//            XCTAssertTrue(object.count == 1)
//        }
//        catch {
//            print(error)
//        }
//    }

    
}
