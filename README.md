# CWCoreData

[![CI Status](http://img.shields.io/travis/Chris Wunsch/CWCoreData.svg?style=flat)](https://travis-ci.org/Chris Wunsch/CWCoreData)
[![Version](https://img.shields.io/cocoapods/v/CWCoreData.svg?style=flat)](http://cocoapods.org/pods/CWCoreData)
[![License](https://img.shields.io/cocoapods/l/CWCoreData.svg?style=flat)](http://cocoapods.org/pods/CWCoreData)
[![Platform](https://img.shields.io/cocoapods/p/CWCoreData.svg?style=flat)](http://cocoapods.org/pods/CWCoreData)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

This library requires to following:

<ul>
<li>Xcode 8.0+</li>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>

## Installation

CWCoreData is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CWCoreData"
```

## Author

Minty Water Ltd

Chris Wunsch, chris@mintywater.co.uk

## License

CWCoreData is available under the MIT license. See the LICENSE file for more info.

## Contribute

We accept pull requests!

## Usage

The library is very easy to use, the only setup code you need is to tell it what the name of your xcdatamodeld is, if you are using cocoapods you must also import the module, see the sample code below:

```swift
/// If using CocoaPods
import CWCoreData

/// Tell the framework what your xcdatamodeld is called, if you forgot this the framework will raise an exception:
CoreDataStack.defaultStack.dataBaseName = "YOU_DATABASE_NAME"

```

### Insert new objects

To insert a new object into the database - this assumes the Entity name is 'Event' as per the example project. The following sample will show you how to do this in iOS 10 and below, if you are targeting iOS 10, then you can omit the else:

```swift

/// Create a new context to use for the insertion, we always use the 'privateQueueContext' to handle database changes. This will merge change back into the persistent store coordinator.
let context = CoreDataStack.privateQueueContext()

/// Create a new var to hold the event object:   
var newEvent : Event?

/// If we are running on iOS 10 then we can use the new API to insert:
if #available(iOS 10.0, *) {
    newEvent = Event(context: context)
} else {
    /// If we are using anything before iOS 10, then we use the helper method from the extension on NSManangedObject
    newEvent = Event.insertNewInstance(withContext: context) as? Event
}
                
/// If appropriate, configure the new managed object.
newEvent?.timestamp = NSDate()

/// We now save the changes, this can throw:
do {
    /// We now save the context and in this case have provided a completion block so we know once the changed has been merged back into the persistent store coordinator:
    try CoreDataStack.defaultStack.saveContext(context) { (context) in
        print(context)
    }
}
catch {
    /// Catch and handle any errors
    print(error)
}

```

### Retrieve existing object

The framework has an NSManangedObject extension that adds some helper methods for retreiving objects. The following code sample shows how an object can be retrieved with a simple predicate:

```swift
do {
            
    /// We use the main context for retrieval if we are going to use the obejct to populate the UI and we are NOT going to make direct changes to the object. Otherwise use the privateQeueContext.
    let context = CoreDataStack.defaultStack.mainQueueContext

    /// Create the predicate we will use:
    let predicate = NSPredicate(format: "timestamp < %@", NSDate())
    
    /// Get the event from the database if one exists with the provided predicate, there are other APIs that do similar operations with more options. See documentation.
    let savedEvent = try Event.fetchSingleObject(withPredicate: predicate, context: context, includesPendingChanges: true) as? Event

}
    
} catch {
    print("error")
}

```

### Delete an object

Deleting an object is easy

```swift

/// Create a new context to use for the deletion, we always use the 'privateQueueContext' to handle database changes. This will merge change back into the persistent store coordinator.
let context = CoreDataStack.privateQueueContext()
            
do {

    let objectToDelete = /// Your Object...
    
    /// Delete the object:
    context.delete(objectToDelete)

    /// Save the changes, we don't supply a completion handler here:
    try CoreDataStack.defaultStack.saveContext(context, completionHandler: nil)

} catch {

    /// Handle any errors:
    print(error)
}

```


### Fetched Results Controller

Setting up a fetched results controller is simple when using the CWCoreData. This will automatically update when any changes are made to the DB using the 'privateQueueContext'

```swift
/// Create a var for the fetched results controller:
var fetchedResultsController: NSFetchedResultsController<Event> {
    
    if _fetchedResultsController != nil {
        return _fetchedResultsController!
    }
    
    /// Create the fetch request:
    let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
    
    /// Optional: Set the batch size to a suitable number. 
    fetchRequest.fetchBatchSize = 20
    
    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
    
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    /// Edit the section name key path and cache name if appropriate.
    /// nil for section name key path means "no sections".
    /// We always use the mainQueueContext for FetchedResultsControllers and any other time where we need the UI to be populated from the database object:
    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.defaultStack.mainQueueContext, sectionNameKeyPath: nil, cacheName: nil)
    aFetchedResultsController.delegate = self
    _fetchedResultsController = aFetchedResultsController
    
    do {
        try _fetchedResultsController!.performFetch()
    } catch {
        print(error)
    }
    
    return _fetchedResultsController!
}

var _fetchedResultsController: NSFetchedResultsController<Event>? = nil

```

You can now implement the FetchedResultsController delegates as you wish. 