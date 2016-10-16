//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        Endpoint.baseURI = "http://api.verbix.com"
        Endpoint.apiKey = "35b1e140-257a-11e6-be88-00089be4dcbc/"
        
        let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()!
        
        window?.rootViewController = tabBarController
        
        return true
    }

}
