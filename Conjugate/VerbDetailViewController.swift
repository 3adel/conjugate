//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class VerbDetailViewController: UIViewController {
    @IBOutlet var verbLabel: UILabel!
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var meaningLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var audioButton: UIButton!
    
    let tabbedMenuSegue = "tabbedMenuSegue"
    let tabbedContentSegue = "tabbedContentSegue"
    
    var loadingView: LoadingView?
    let speaker = TextSpeaker(locale: Locale(identifier: "de_DE"))
    
    var presenter: ConjugatePresnterType!
    var viewModel = ConjugateViewModel.empty
    
    var tabbedMenuViewController: TabbedMenuViewController?
    var tabbedContentViewController: TabbedContentViewController?
    
    var tabTableViewDatasources = [TenseTableViewDataSource]()
    var tabTableViews = [UITableView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI(with: viewModel, all: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.updateViewModel()
    }
    
    override func setupUI() {
        super.setupUI()
        
        verbLabel.set(labelType: .regular)
        errorLabel.set(labelType: .regular)
        
        
        navigationItem.backBarButtonItem?.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor.clear
            ],
            for: .normal
        )
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
        
        let textColorRGB: CGFloat = 117/255
        let textColor = UIColor(red: textColorRGB, green: textColorRGB, blue: textColorRGB, alpha: 1)
        let selectedColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1)
        
        let theme = TabbedMenuTheme(textColor: textColor, selectedColor: selectedColor)
        
        tabbedMenuViewController.setTheme(theme)
        
        self.tabbedMenuViewController = tabbedMenuViewController
    }
    
    func setup(tabbedContentViewController: TabbedContentViewController) {
        
        self.tabbedContentViewController = tabbedContentViewController
        self.tabbedContentViewController?.delegate = self
    }
    
}

//Actions
extension VerbDetailViewController {
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        presenter.toggleSavingVerb()
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        if speaker.isPlaying(viewModel.verb) {
            speaker.stop()
            speaker.play(viewModel.verb)
        } else {
            speaker.play(viewModel.verb)
        }
    }
}

extension VerbDetailViewController: ConjugateView {
    func updateUI(with viewModel: ConjugateViewModel) {
        self.updateUI(with: viewModel, all: false)
    }
    func updateUI(with viewModel: ConjugateViewModel, all: Bool ) {
        
        title = viewModel.verb
        
        saveButton.isHidden = viewModel.isEmpty
        shareButton.isHidden = viewModel.isEmpty
        audioButton.isHidden = viewModel.isEmpty
        
        verbLabel.isHidden = viewModel.isEmpty
        errorLabel.isHidden = true
        
        verbLabel.text = viewModel.verb
        languageLabel.text = viewModel.language.isEmpty ? "" : viewModel.language + " - "
        meaningLabel.text = viewModel.meaning
        
        let starImageString = viewModel.starSelected ? "star_selected" : "star"
        
        let starImage = UIImage(named: starImageString)
        
        saveButton.setImage(starImage, for: .normal)
        
        if viewModel.tenseTabs != self.viewModel.tenseTabs || viewModel.verb != self.viewModel.verb || all {
            updateTabs(with: viewModel)
        }
        
        self.viewModel = viewModel
    }
    
    func updateTabs(with viewModel: ConjugateViewModel) {
        tabbedMenuViewController?.contentController = tabbedContentViewController
        tabbedContentViewController?.menuController = tabbedMenuViewController
        
        
        var tabs: [TabbedMenuViewController.Tab] = []
        
        tabTableViews.removeAll()
        tabTableViewDatasources.removeAll()
        
        viewModel.tenseTabs.forEach { tenseViewModel in
            let tableView = UITableView(frame: CGRect.zero, style: .grouped)
            tableView.allowsMultipleSelection = false
            tableView.allowsSelection = true
            tableView.keyboardDismissMode = .onDrag
            
            let dataSource = TenseTableViewDataSource(tableView: tableView)
            
            dataSource.viewModel = tenseViewModel
            
            tabTableViews.append(tableView)
            tabTableViewDatasources.append(dataSource)
            
            let tab = TabbedMenuViewController.Tab(title: tenseViewModel.name, view: tableView)
            tabs.append(tab)
        }
        
        tabbedMenuViewController?.tabs = tabs
        tabbedContentViewController?.views = tabTableViews
    }
    
    func showVerbNotFoundError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}

extension VerbDetailViewController {
    override func showLoader() {
        loadingView = LoadingView.showIn(view: view, withFrame: verbLabel.frame)
        verbLabel.isHidden = true
    }
    
    override func hideLoader() {
        loadingView?.stop()
        loadingView = nil
        
        verbLabel.isHidden = false
    }
    
    func show(errorMessage: String) {
        updateUI(with: ConjugateViewModel.empty)
        
        errorLabel.text = errorMessage
        errorLabel.isHidden = false
    }
    
    func hideErrorMessage() {
        errorLabel.isHidden = true
    }
}

extension VerbDetailViewController: TabbedContentDelegate {
    func tabbedViewDidScroll(_ scrollView: UIScrollView) {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

