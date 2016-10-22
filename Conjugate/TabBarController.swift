//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    enum Tab: String {
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
        Tab.allTabs.forEach {
            guard let tabNavigationController = storyboard?.instantiateViewController(withIdentifier: $0.navigationControllerIdentifier),
                let tabImage = $0.image else { return }
            
            let tabBarItem = UITabBarItem(title: $0.name, image: tabImage, tag: 0)
            tabNavigationController.tabBarItem = tabBarItem
            
            tabNavigationController.navigationController?.navigationBar.tintColor = Theme.mainTintColor
            
            controllers.append(tabNavigationController)
        }
        
        viewControllers = controllers
    }
}
