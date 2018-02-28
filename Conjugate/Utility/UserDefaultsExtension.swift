//
//  UserDefaultsExtensions.swift
//  Texture
//
//  Created by Halil Gursoy on 21.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import Foundation

protocol UserDefaultsKey {
    var keyValue: String { get }
}

extension RawRepresentable where RawValue == String, Self: UserDefaultsKey {
    var keyValue: String { return rawValue }
}

extension UserDefaults {
    enum Key: String, UserDefaultsKey {
        case didShowDerSatzPromotion
    }
    
    var didShowDerSatzPromotion: Bool {
        get { return value(for: Key.didShowDerSatzPromotion) ?? false }
        set { set(newValue, for: Key.didShowDerSatzPromotion) }
    }
    
    func value<T>(for key: UserDefaultsKey) -> T? {
        if T.self == Bool.self {
            return bool(forKey: key.keyValue) as? T
        } else {
            return value(forKey: key.keyValue) as? T
        }
    }
    
    func set<T: Any>(_ value: T, for key: UserDefaultsKey) {
        set(value, forKey: key.keyValue)
    }
}

