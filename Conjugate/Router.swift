//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class Router {
    
    let rootViewController: UIViewController
    
    init(viewController: UIViewController) {
        self.rootViewController = viewController
    }
    
    convenience init?(view: View) {
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
        
        rootViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func show(viewController: UIViewController) {
        rootViewController.present(viewController, animated: true, completion: nil)
    }
    
    func present(sheetViewController viewController: UIViewController, sourceView: UIView? = nil, sourceRect: CGRect? = nil) {
        if isPad() {
            viewController.modalPresentationStyle = .popover
            viewController.popoverPresentationController?.sourceView = sourceView
            if let sourceRect = sourceRect {
                viewController.popoverPresentationController?.sourceRect = sourceRect
            }
        }
        rootViewController.present(viewController, animated: true, completion: nil)
    }
    
    func dismiss() {
        rootViewController.dismiss(animated: true, completion: nil)
    }
}

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
}
