//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var router: Router?
    
    enum Tab: String {
        case conjugate
        case saved
        case more
        
        var navigationControllerIdentifier: String {
            return self.rawValue+"NavigationController"
        }
        
        var imageString: String {
            return self.rawValue+"_tab"
        }
        
        var image: UIImage? {
            return UIImage(named: imageString)
        }
        
        var name: String {
            switch self {
            case .saved:
                return "Saved Verbs"
            default:
                return rawValue.capitalized
            }
        }
        
        static var allTabs: [Tab] {
            return [
                .conjugate,
                .saved,
                .more
            ]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = UIColor.white
        
        router?.isViewReady = true
    }
    
    func setupTabs() {
        var controllers = [UIViewController]()
        Tab.allTabs.forEach {
            guard let tabNavigationController = storyboard?.instantiateViewController(withIdentifier: $0.navigationControllerIdentifier) as? UINavigationController,
                let tabImage = $0.image else { return }
            
            let tabBarItem = UITabBarItem(title: $0.name, image: tabImage, tag: 0)
            tabNavigationController.tabBarItem = tabBarItem
            
            tabNavigationController.navigationBar.tintColor = Theme.mainTintColor
            tabNavigationController.viewControllers.first?.title = $0.name
            
            controllers.append(tabNavigationController)
        }
        
        viewControllers = controllers
        
        router?.setupTabs()
    }
}
