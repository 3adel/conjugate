//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class Router {
    
    let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    convenience init?(view: SavedVerbView) {
        guard let viewController = view as? UIViewController
            else { return nil }
        self.init(viewController: viewController)
    }
    
    func openDetail(of verb: Verb) {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "VerbDetailViewController") as? VerbDetailViewController
            else { return }
        
        let conjugatePresenter = ConjugatePresenter(view: vc)
        vc.presenter = conjugatePresenter
        vc.viewModel = conjugatePresenter.makeConjugateViewModel(from: verb)
        
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
}
