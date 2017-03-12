//
//  AppLaunchChecker.swift
//  Conjugate
//
//  Created by Halil Gursoy on 31/10/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation


class AppLaunchChecker {
    var isFirstInstall: Bool {
        return UserDefaults.standard.value(forKey: UserDefaultKeys.IsFirstInstall) as? Bool ?? true
    }
    
    func appDidLaunch() {
        UserDefaults.standard.set(false, forKey: UserDefaultKeys.IsFirstInstall)
    }
}
