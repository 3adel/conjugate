//
//  NotificationName.swift
//  Conjugate
//
//  Created by Halil Gursoy on 05/03/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation


/**
 Protocol for Notification names
 */
public protocol NotificationName {
    var name: Notification.Name { get }
}

/**
 Extending enums of type string to add a 'name' property to conform to the NotificationName protocol
 */
public extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

/**
 Protocol for objects observing NSNotifications
 */
public protocol NotificationObserver: class {
    var observedNotifications: [(NotificationName, Selector)] { get }
    
    func subscribeForNotifications()
    func unsubscribeForNotifications()
}

public extension NotificationObserver {
    
    func subscribeForNotifications() {
        observedNotifications.forEach { observedNotification in
            let notification = observedNotification.0
            let selector = observedNotification.1
            
            NotificationCenter.default.addObserver(self, selector: selector, name: notification.name, object: nil)
        }
    }
    
    func unsubscribeForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

public protocol NotificationSender: class {
    func send(_ notificationName: NotificationName, userInfo: [AnyHashable: Any]?)
}

public extension NotificationSender {
    func send(_ notificationName: NotificationName, userInfo: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: notificationName.name, object: nil, userInfo: userInfo)
    }
}
