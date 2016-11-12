//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        

        Fabric.with([Crashlytics.self])
        
        Endpoint.baseURI = "http://api.verbix.com"
        Endpoint.apiKey = "35b1e140-257a-11e6-be88-00089be4dcbc/"
        
        let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()!
        
        window?.rootViewController = tabBarController
        
        //facebook analytics tracking
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        //facebook analytics tracking
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //facebook analytics tracking
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    
    
}
