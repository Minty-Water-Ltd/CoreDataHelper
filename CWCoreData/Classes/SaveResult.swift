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
    
    /// The failure result. Supplies an error that specifies what went wrong
    case failure(NSError)
    
    /// MARK: Methods
    
    /// Return the error in the save result:
    ///
    /// - Returns: the error or nil
    public func error() -> NSError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
