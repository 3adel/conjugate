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
    
    var quickActionController = QuickActionController()
    
    var router: Router?
    var appDependencyManager: AppDependencyManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        appDependencyManager = AppDependencyManager.configuringDefault()
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -80.0), for: .default)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .normal)
        
        Fabric.with([Crashlytics.self])
        
        Endpoint.baseURI = "http://api.verbix.com"
        Endpoint.apiKey = "35b1e140-257a-11e6-be88-00089be4dcbc/"
        
        let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() as! TabBarController
        
        window?.rootViewController = tabBarController
        
        router = Router(viewController: tabBarController)
        
        tabBarController.router = router
        
        if let shortcutItems = UIApplication.shared.shortcutItems {
            quickActionController.update(from: shortcutItems)
        }
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            performAction(for: shortcutItem)
        }
        
        //facebook analytics tracking
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
      
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        //facebook analytics tracking
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        performAction(for: shortcutItem)
    }
    
    func performAction(for shortcutItem: UIApplicationShortcutItem) {
        guard let quickAction = quickActionController.makeQuickAction(from: shortcutItem) else { return }
        
        router?.route(using: quickAction)
    }
    
    //facebook analytics tracking
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
}

extension AppDelegate {
    override class func initialize() {
        AppDelegate.setupAppReviewController()
    }
    
    class func setupAppReviewController() {
        AppReviewController.with(appID: "1163600729")
    }
}
