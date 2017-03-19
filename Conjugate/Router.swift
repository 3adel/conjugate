//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class Router {
    
    enum PresenterType {
        case conjugate, savedVerb, settings
    }
    
    let rootViewController: UIViewController
    let appDependencyManager: AppDependencyManager
    
    let presenterViewLookupTable: [String: PresenterType] = [
        ConjugateViewController.Identifier : .conjugate,
        SavedVerbsViewController.Identifier : .savedVerb,
        MoreViewController.Identifier : .settings
    ]
    
    var isViewReady = false {
        didSet {
            if let quickAction = quickActionToBePerformed,
                isViewReady {
                route(using: quickAction)
                quickActionToBePerformed = nil
            }
        }
    }
    
    var quickActionToBePerformed: QuickAction?
    
    init(viewController: UIViewController, appDependencyManager: AppDependencyManager = .shared) {
        self.rootViewController = viewController
        self.appDependencyManager = appDependencyManager
    }
    
    convenience init?(view: View) {
        guard let viewController = view as? UIViewController
            else { return nil }
        self.init(viewController: viewController)
    }
    
    fileprivate var visibleController: UIViewController {
        return UIWindow.visibleViewControllerFrom(self.rootViewController)
    }
    
    func setupTabs() {
        guard let tabBarController = rootViewController as? TabBarController else { return }
        
        tabBarController.viewControllers?.forEach { viewController in
            guard let rootNavigationViewController = viewController as? UINavigationController,
                let initalViewController = rootNavigationViewController.viewControllers.first else { return }
            
            let viewControllerType = type(of: initalViewController)
            
            guard let presenterType = presenterViewLookupTable[viewControllerType.Identifier] else { return }
            
            switch presenterType {
            case .conjugate:
                guard let conjugateViewController = initalViewController as? ConjugateViewController,
                    let presenter = makeConjugatePresenter(with: conjugateViewController) else { break }
                conjugateViewController.presenter = presenter
            default:
                break
            }
        }
    }
    
    static func makeOnboardingView() -> OnboardingLanguageSelectionViewController? {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: OnboardingLanguageSelectionViewController.Identifier) as? OnboardingLanguageSelectionViewController,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let presenter = OnboardingPresenter(view: vc, appDependencyManager: .shared, languages: AppDependencyManager.shared.languageConfig.availableConjugationLanguages, delegate: appDelegate)
        
        vc.presenter = presenter
        
        return vc
    }
    
    func openSearch(withVerb verb: String) {
        let tabBarController = rootViewController as? TabBarController
        tabBarController?.selectedIndex = 0
        
        guard let presenter = (visibleController as? ConjugateViewController)?.presenter as? ConjugatePresenter else { return }
        presenter.verbToBeSearched = verb
    }
    
    func openDetail(of verb: Verb) {
        guard let vc = makeDetailView(from: verb) else { return }
        rootViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openLanguageSelection(languages: [Language], selectedLanguage: Language, languageType: LanguageType) {
        guard let vc = makeLanguageSelectionViewController() else { return }
        
        let presenter = LanguageSelectionPresenter(view: vc, appDependencyManager: AppDependencyManager.shared, languages: languages, selectedLanguage: selectedLanguage, languageType: languageType)
        vc.presenter = presenter
        
        rootViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func makeDetailViewController(from verb: Verb) -> VerbDetailViewController? {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "VerbDetailViewController") as? VerbDetailViewController
            else { return nil}
        return vc
    }
    
    func makeDetailView(from verb: Verb) -> VerbDetailViewController? {
        guard let vc = makeDetailViewController(from: verb),
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { return nil }
        
        let conjugatePresenter = ConjugatePresenter(view: vc, appDependencyManager: appDependencyManager, quickActionController: appDelegate.quickActionController)
        vc.presenter = conjugatePresenter
        vc.viewModel = conjugatePresenter.makeConjugateViewModel(from: verb)
        
        return vc
    }
    
    func makeConjugatePresenter(with viewController: ConjugateViewController) -> ConjugatePresenter? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { return nil }
        
        return ConjugatePresenter(view: viewController, appDependencyManager: appDependencyManager, quickActionController: appDelegate.quickActionController)
    }
    
    func makeLanguageSelectionViewController() -> LanguageSelectionViewController? {
        return UIStoryboard.main.instantiateViewController(withIdentifier: LanguageSelectionViewController.Identifier) as? LanguageSelectionViewController
    }
    
    func route(using quickAction: QuickAction) {
        guard isViewReady else {
            quickActionToBePerformed = quickAction
            return
        }
        
        if quickAction.type == .search {
            openSearch(withVerb: quickAction.title)
        }
    }
    
    func show(viewController: UIViewController) {
        rootViewController.present(viewController, animated: true, completion: nil)
    }
    
    func show(view: View) {
        guard let vc = view as? UIViewController else { return }
        show(viewController: vc)
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
        if let navigationVC = rootViewController.navigationController {
            navigationVC.popViewController(animated: true)
        } else {
            rootViewController.dismiss(animated: true, completion: nil)
        }
    }
}

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
}

fileprivate extension UIWindow {
    
    class func visibleViewControllerFrom(_ vc: UIViewController) -> UIViewController {
        var visibleController: UIViewController?
        switch vc {
        case let vc as UINavigationController:
            visibleController = vc.visibleViewController
        case let vc as UITabBarController:
            guard let selectedVC = vc.selectedViewController else { break }
            visibleController = selectedVC
        case let vc as UISplitViewController:
            if let detailViewController = vc.viewControllers.last {
                visibleController = detailViewController
            }
        case let vc as UISearchController:
            return vc.presentingViewController!
        case let vc where vc.presentedViewController != nil:
            visibleController = vc.presentedViewController!
        default:
            break
        }
        return visibleController != nil ? visibleViewControllerFrom(visibleController!) : vc
    }
}
