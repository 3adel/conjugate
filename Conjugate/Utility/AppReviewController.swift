//
//  AppReviewController.swift
//  Conjugate
//
//  Created by Halil Gursoy on 04/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Armchair

class AppReviewController {
    let significantEventsUntilPrompt: UInt = 5
    let daysUntilPrompt: UInt = 0
    let usesUntilPrompt: UInt = 0
    
    var appID: String = ""
    
    private init() {}
    
    private func update(appID: String) {
        self.appID = appID
        
        Armchair.appID(appID)
        Armchair.significantEventsUntilPrompt(significantEventsUntilPrompt)
        Armchair.daysUntilPrompt(daysUntilPrompt)
        Armchair.usesUntilPrompt(usesUntilPrompt)
    }
    
    //MARK: Static functions
    @discardableResult
    static func with(appID: String) -> AppReviewController {
        let instance = sharedInstance
        instance.update(appID: appID)
        
        return instance
    }
    
    static let sharedInstance: AppReviewController = {
        let instance = AppReviewController()
        return instance
    }()
    
    //MARK: Instance functions
    
    func didSignificantEvent() {
        Armchair.userDidSignificantEvent(true)
    }
}
