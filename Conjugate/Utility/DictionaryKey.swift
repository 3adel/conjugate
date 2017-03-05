//
//  DictionaryKey.swift
//  Conjugate
//
//  Created by Halil Gursoy on 05/03/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation


/**
 Protocol for dictionary keys
 */
public protocol DictionaryKey {
    var key: String { get }
}

/**
 Extending enums of type string to add a 'key' property to conform to the DictionaryKey protocol
 */
public extension RawRepresentable where RawValue == String, Self: DictionaryKey {
    var key: String {
        get {
            return self.rawValue
        }
    }
}
