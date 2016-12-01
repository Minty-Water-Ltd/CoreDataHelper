//
//  SaveResult.swift
//  Pods
//
//  Created by Chris Wunsch on 01/12/2016.
//
//

import Foundation
import CoreData

public enum SaveResult {
    
    /// The success result.
    case success
    
    /// The failure result, containing an `NSError` instance that describes the error.
    case failure(NSError)
    
    
    /// MARK: Methods
    
    public func error() -> NSError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
