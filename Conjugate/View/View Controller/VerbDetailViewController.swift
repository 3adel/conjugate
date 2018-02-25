//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class VerbDetailViewController: UIViewController {
    @IBOutlet private var verbLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var nominalLabel: UILabel!
    @IBOutlet private var meaningLabel: UILabel!
    @IBOutlet private var exampleSentencesLabel: UILabel!
    @IBOutlet private var errorLabel: UILabel!
    
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var shareButton: UIButton!
    @IBOutlet private var audioButton: AnimatedButton!
    
    @IBOutlet private var translationLanguageImageView: UIImageView!
    
    @IBOutlet private var nominalFormHeightConstraint: NSLayoutConstraint!
    
    let tabbedMenuSegue = "tabbedMenuSegue"
    let tabbedContentSegue = "tabbedContentSegue"
    
    var loadingView: LoadingView?
    
    var presenter: ConjugatePresenterType?
    var viewModel = ConjugateViewModel.empty
    
    var alertHandler: AlertHandler?
    
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
        presenter?.updateViewModel()
        
        let showNavBar = parent is UINavigationController
        
        navigationController?.isNavigationBarHidden = !showNavBar
    }
    
    override func setupUI() {
        super.setupUI()
        
        verbLabel.set(labelType: .regular)
        errorLabel.set(labelType: .regular)
        
        exampleSentencesLabel.font = exampleSentencesLabel.font.italic
        
        audioButton.images = [#imageLiteral(resourceName: "speaker_1"), #imageLiteral(resourceName: "speaker"), #imageLiteral(resourceName: "speaker_3")]

        alertHandler = AlertHandler(view: view, topLayoutGuide: topLayoutGuide, bottomLayoutGuide: bottomLayoutGuide)
        
        navigationItem.backBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.clear],
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
        presenter?.toggleSavingVerb()
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        presenter?.playAudioForInfinitveVerb()
    }
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        presenter?.shareVerb(sourceView: sender)
    }
}

extension VerbDetailViewController: ConjugateView {
    func hideTranslationList() {}
    
    func updateUI(with viewModel: ConjugateViewModel) {
        self.updateUI(with: viewModel, all: false)
    }
    func updateUI(with viewModel: ConjugateViewModel, all: Bool ) {
        
        title = viewModel.verb
        
        [saveButton, shareButton, audioButton, verbLabel, nominalLabel, infoLabel, meaningLabel, exampleSentencesLabel].forEach { $0.isHidden = viewModel.isEmpty }
        
        errorLabel.isHidden = true
        
        translationLanguageImageView.image = UIImage(named: viewModel.switchInterfaceLanguageFlagImage)
        translationLanguageImageView.isHidden = viewModel.isEmpty
        
        verbLabel.text = viewModel.verb
        nominalLabel.text = viewModel.nominalForms
        infoLabel.attributedText = viewModel.infoText
        meaningLabel.text = viewModel.meaning
        exampleSentencesLabel.text = viewModel.exampleSentences
        
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
            
            dataSource.language = viewModel.speakerLanguage
            
            let tabIndex = viewModel.tenseTabs.index(of: tenseViewModel) ?? 0
            dataSource.onRowDidSelect = { [weak self] row, section in
                self?.presenter?.tappedForm(inTab: tabIndex, atTense: section, at: row)
            }
            
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
    
    func animateInfinitveAudioButton() {
        audioButton.startAnimating()
    }
    
    func stopAnimatingInfinitiveAudioButton() {
        audioButton.stopAnimating()
    }
    
    func show(successMessage: String) {
        alertHandler?.show(succesMessage: successMessage)
    }
    
    func showActionsForForm(inTab tab: Int, atTense tense: Int, at index: Int) {
        let actionController = ActionController(viewController: self.parent ?? self)
        
        let titles = ["Copy", "Share"]
        
        let source = getSource(inTab: tab, atTense: tense, atForm: index)
        
        let copyAction: ()->() = {
            self.presenter?.copyForm(inTab: tab, atTense: tense, at: index)
        }
        
        let shareAction: ()->() = {
            self.presenter?.shareForm(inTab: tab, atTense: tense, at: index, sourceView: source.sourceView, sourceRect: source.sourceRect)
        }
        
        let actions = [copyAction, shareAction]
        actionController.showActions(withTitles: titles, actions: actions, sourceView: source.sourceView, sourceRect: source.sourceRect)
    }
    
    func getSource(inTab tabIndex: Int, atTense tenseIndex: Int, atForm formIndex: Int) -> (sourceView: View, sourceRect: CGRect) {
        let dataSource = self.tabTableViewDatasources[tabIndex]
        let rectForCell = dataSource.tableView.rectForRow(at: IndexPath(row: formIndex, section: tenseIndex))
        return (sourceView: dataSource.tableView, sourceRect: rectForCell)
    }
}

extension VerbDetailViewController {
    override func showLoader() {
        guard loadingView == nil else { return }
        
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

