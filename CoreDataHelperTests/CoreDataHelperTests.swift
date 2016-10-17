//
//  CoreDataHelperTests.swift
//  CoreDataHelperTests
//
//  Created by Chris Wunsch on 16/10/2016.
//  Copyright © 2016 Minty Water Ltd. All rights reserved.
//

import XCTest
@testable import CoreDataHelper

class CoreDataHelperTests: XCTestCase {
    
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
    
    func testSaveOfObject() {
        
        let mainContext = CoreDataStack.defaultStack.mainQueueContext()
        
        let privateContext = CoreDataStack.defaultStack.privateQueueContext()

        let newEvent = Event(context: privateContext)
        
        // If appropriate, configure the new managed object.
        newEvent.timestamp = NSDate()
        
        do {
            try CoreDataStack.defaultStack.saveContext(privateContext, completionHandler: nil)
            let objectID = try mainContext.existingObject(with: newEvent.objectID)
            XCTAssertNotNil(objectID)
        }
        catch {
            print(error)
        }
        

    }
    
    func testThrowOnMainContextSave() {
        
        let mainContext = CoreDataStack.defaultStack.mainQueueContext()
        
        let newEvent = Event(context: mainContext)
        
        // If appropriate, configure the new managed object.
        newEvent.timestamp = NSDate()
        
        do {
            try CoreDataStack.defaultStack.saveContext(mainContext, completionHandler: nil)
        }
        catch {
            XCTAssertNotNil(error)
        }
    }
}
