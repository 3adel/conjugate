//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class SavedVerbsViewController: UIViewController {
    @IBOutlet var noVerbsLabel: UILabel!
    @IBOutlet var noVerbsImageView: UIImageView!
    
    @IBOutlet weak var menuHeightConstraint: NSLayoutConstraint!
    
    let tabbedMenuSegue = "tabbedMenuSegue"
    let tabbedContentSegue = "tabbedContentSegue"
    
    var presenter: SavedVerbPresenterType!
    
    var alertHandler: AlertHandler?
    
    var previewDelegate: SavedVerbPreviewingDelegate?
    
    var tabbedMenuViewController: TabbedMenuViewController?
    var tabbedContentViewController: TabbedContentViewController?
    var selectedTab: Int = 0
    
    var tabTableViewDatasources = [SavedVerbDataSource]()
    var tabTableViews = [UITableView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.getSavedVerbs()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    func setupPresenter() {
        presenter = SavedVerbPresenter(view: self)
    }
    
    override func setupUI() {
        setStatusBar(backgroundColor: UIColor.white)
        
        navigationController?.navigationBar.tintColor = Theme.mainTintColor
        alertHandler = AlertHandler(view: view, topLayoutGuide: topLayoutGuide, bottomLayoutGuide: bottomLayoutGuide)
        
        noVerbsLabel.text = ConjugateError.noSavedVerbs.localizedDescription
    }
    
    fileprivate func setupPreviewDelegate(with tableView: UITableView) {
        previewDelegate = SavedVerbPreviewingDelegate(tableView: tableView, tab: selectedTab, getVerbDetailView: { index in
            return self.presenter.getVerbDetailView(at: index, ofLanguageAt: self.selectedTab) as? VerbDetailViewController
        },
                                                      openVerbDetail: presenter.openVerbDetails)
        if let previewDelegate = previewDelegate {
            registerForPreviewing(with: previewDelegate, sourceView: tableView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tabbedMenuSegue {
            guard let
                menuViewController = segue.destination as? TabbedMenuViewController
                else { return }
            setup(tabbedMenuViewController: menuViewController)
        } else if segue.identifier == tabbedContentSegue {
            guard let
                tabContentViewController = segue.destination as? TabbedContentViewController
                else { return }
            setup(tabbedContentViewController: tabContentViewController)
        }
    }
    
    func setup(tabbedMenuViewController: TabbedMenuViewController) {
        self.tabbedMenuViewController = tabbedMenuViewController
    }
    
    func setup(tabbedContentViewController: TabbedContentViewController) {
        self.tabbedContentViewController = tabbedContentViewController
        self.tabbedContentViewController?.delegate = self
    }
}

extension SavedVerbsViewController: SavedVerbView {
    func update(with viewModel: SavedVerbViewModel) {
        setupTabs(languageViewModels: viewModel.savedVerbLanguages)
        
        tabbedContentViewController?.view.isHidden = !viewModel.showVerbsList
        noVerbsLabel.isHidden = !viewModel.showNoSavedVerbMessage
        noVerbsImageView.isHidden = noVerbsLabel.isHidden
        tabbedContentViewController?.changeIndex(to: selectedTab, animated: false)
    }
    
    func setupTabs(languageViewModels: [SavedVerbLanguageViewModel]) {
        tabbedMenuViewController?.contentController = tabbedContentViewController
        tabbedContentViewController?.menuController = tabbedMenuViewController
        
        setupTabTheme(with: languageViewModels)
        
        var tabs: [TabbedMenuViewController.Tab] = []
        
        tabTableViews.removeAll()
        tabTableViewDatasources.removeAll()
        
        languageViewModels.forEach { languageViewModel in
            let tableView = UITableView(frame: CGRect.zero, style: .grouped)
            tableView.allowsMultipleSelection = false
            tableView.allowsSelection = true
            
            let dataSource = SavedVerbDataSource(tableView: tableView, verbs: languageViewModel.savedVerbs)
            
            dataSource.onVerbDidSelect = { [weak self] index in
                guard let strongSelf = self else { return }
                
                strongSelf.presenter.openVerbDetails(at: index, ofLanguageAt: strongSelf.selectedTab)
            }
            
            dataSource.onVerbShouldDelete = { [weak self] index in
                guard let strongSelf = self else { return }
                
                strongSelf.presenter.deleteVerb(at: index, ofLanguageAt: strongSelf.selectedTab)
            }
            
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
            
            tabTableViews.append(tableView)
            tabTableViewDatasources.append(dataSource)
            
            let flagImage = UIImage(named: languageViewModel.flagImageName)
            let imageSize = CGSize(width: 14, height: 14)
            
            let tab = TabbedMenuViewController.Tab(title: languageViewModel.name.uppercased(), image: flagImage, imageSize: imageSize, view: tableView)
            tabs.append(tab)
        }
        
        tabbedMenuViewController?.tabs = tabs
        tabbedContentViewController?.views = tabTableViews
        tabbedContentViewController?.isScrollEnabled = false
        
//        if tabs.count <= 1 {
//            menuHeightConstraint.constant = 0
//        } else {
            menuHeightConstraint.constant = 44
//        }
    }
    
    func setupTabTheme(with languageViewModels: [SavedVerbLanguageViewModel]) {
        
        let borderColor = UIColor.clear
        let textColor = UIColor.black
        let selectedColors: [UIColor] = languageViewModels.map { languageViewModel in
            return UIColor(red: languageViewModel.tintColor.0/255,
                           green: languageViewModel.tintColor.1/255,
                           blue: languageViewModel.tintColor.2/255,
                           alpha: 1.0)
            
        }//UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1)
        let font = UIFont.boldSystemFont(ofSize: 13)
        
        let theme = TabbedMenuTheme(textColor: textColor, selectedColors: selectedColors, font: font, borderColor: borderColor)
        
        tabbedMenuViewController?.setTheme(theme)
    }
    
    func show(successMessage: String) {
        alertHandler?.show(succesMessage: successMessage)
    }
}

extension SavedVerbsViewController: TabbedContentDelegate {
    func tabbedViewDidScroll(toTabAt index: Int) {
        selectedTab = index
        let tableView = tabTableViews[index]
        setupPreviewDelegate(with: tableView)
    }
}

class SavedVerbPreviewingDelegate: NSObject, UIViewControllerPreviewingDelegate {
    let tableView: UITableView
    let getVerbDetailView: (_: Int) -> VerbDetailViewController?
    let openVerbDetail: (_: Int, _: Int) -> ()
    let tab: Int
    
    var index = 0
    
    
    init(tableView: UITableView, tab: Int, getVerbDetailView: @escaping (_: Int) -> VerbDetailViewController?, openVerbDetail: @escaping (_: Int, _: Int) -> ()) {
        self.tableView = tableView
        self.tab = tab
        self.getVerbDetailView = getVerbDetailView
        self.openVerbDetail = openVerbDetail
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        
        index = indexPath.row
        return getVerbDetailView(index)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        previewingContext.sourceRect = tableView.rectForRow(at: IndexPath(row: index, section: 0))
        openVerbDetail(self.index, tab)
    }
}
