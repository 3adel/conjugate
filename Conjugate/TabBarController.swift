//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    enum Tabs: String {
        case conjugate
        case saved
        
        var navigationControllerIdentifier: String {
            return self.rawValue+"NavigationController"
        }
        
        var imageString: String {
            return self.rawValue+"_tab"
        }
        
        var image: UIImage? {
            return UIImage(named: imageString)
        }
        
        static var allTabs: [Tabs] {
            return [
                .conjugate,
                .saved
            ]
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        
        tabBar.backgroundColor = UIColor.white
    }
    
    private func setupTabs() {
        var controllers = [UIViewController]()
        Tabs.allTabs.forEach {
            guard let tabNavigationController = storyboard?.instantiateViewController(withIdentifier: $0.navigationControllerIdentifier),
                let tabImage = $0.image else { return }
            
            let tabBarItem = UITabBarItem(title: $0.rawValue, image: tabImage, tag: 0)
            tabNavigationController.tabBarItem = tabBarItem
            
            controllers.append(tabNavigationController)
        }
        
        viewControllers = controllers
    }
}
