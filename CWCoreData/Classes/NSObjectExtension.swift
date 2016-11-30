//
//  NSObjectExtension.swift
//  CAT
//
//  Created by Chris Wunsch on 19/10/2016.
//  Copyright © 2016 SGP Consulting. All rights reserved.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
