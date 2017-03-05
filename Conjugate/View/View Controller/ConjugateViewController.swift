//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit


class ConjugateViewController: UIViewController {
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchField: FlexLanguageTextField!
    @IBOutlet weak var searchLanguageSwitch: SevenSwitch!
    
    let verbDetailSegue = "verbDetailSegue"
    
    var loadingView: LoadingView?
    var alertHandler: AlertHandler?
    
    var presenter: ConjugatePresenterType?
    var verbDetailViewController: VerbDetailViewController?
    
    var searchTimer: Timer?
    
    var viewModel = ConjugateViewModel.empty
    var searchText = ""
    
    var translationTableView: UITableView?
    var translationOverlayView: UIView?
    var translationDataSource: TranslationDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        presenter?.getInitialData()
        
        let launchChecker = AppLaunchChecker()
        if launchChecker.isFirstInstall {
            let welcomeVerb = "begrüßen"
            searchField.text = welcomeVerb
            searchText = welcomeVerb
            search()
            
            launchChecker.appLaunched()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.updateViewModel()
    }
    
    override func setupUI() {
        super.setupUI()
        
        setupSearchLanguageSwitch()
        
        searchField.locale = "de_DE"
        
        navigationController?.isNavigationBarHidden = true
        
        searchView.layer.cornerRadius = 4
        searchView.layer.borderWidth = 1
        
        searchField.delegate = self
        
        let grayColor: CGFloat = 230/255.0
        searchView.layer.borderColor = UIColor(red: grayColor, green: grayColor, blue: grayColor, alpha: 1.0).cgColor
        
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        alertHandler = AlertHandler(view: view, topLayoutGuide: topLayoutGuide, bottomLayoutGuide: bottomLayoutGuide)
    }
    
    func setupSearchLanguageSwitch() {
        searchLanguageSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
    }
    
    func search() {
        let minNumOfCharacters = 2
        if searchText.characters.count >= minNumOfCharacters {
            presenter?.search(for: searchText.lowercased())
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == verbDetailSegue {
            guard let viewController = segue.destination as? VerbDetailViewController
                else { return }
            self.verbDetailViewController = viewController
            self.verbDetailViewController?.presenter = presenter
        }
    }
    
    func switchChanged(_ sender: SevenSwitch) {
        let language = sender.isOn() ? viewModel.switchInterfaceLanguage : viewModel.switchSearchLanguage
        presenter?.searchLanguageChanged(to: language)
    }
}

extension ConjugateViewController: ConjugateView {
    func update(searchLanguage: String, searchFieldPlaceholder: String) {
        let searchLanguageSwitchOn = searchLanguage == viewModel.switchInterfaceLanguage
        searchLanguageSwitch.setOn(searchLanguageSwitchOn, animated: false)
        
        searchField.placeholder = searchFieldPlaceholder
    }
    
    func render(with viewModel: TranslationsViewModel) {
        guard !viewModel.translations.isEmpty
            else {
                hideTranslationTableView()
                return
        }
        
        if let translationTableView = translationTableView,
            let dataSource = translationDataSource {
            
            dataSource.translations = viewModel.translations
            translationTableView.reloadData()
            
            changeTranslationTableViewHeight(translationTableView, dataSource: dataSource)
        } else {
            setupTranslationTableView(with: searchView)
            
            guard let tableView = translationTableView else { return }
            setupTranslationDataSource(for: tableView)
            
            translationDataSource?.translations = viewModel.translations
            tableView.reloadData()
            
            guard let overlayView = translationOverlayView,
                let dataSource = translationDataSource
                else { return }
            
            showTranslationTableView(tableView, searchView: searchView, overlayView: overlayView, dataSource: dataSource)
        }
    }
    func updateUI(with viewModel: ConjugateViewModel) {
        self.viewModel = viewModel
        
        searchField.placeholder = viewModel.searchFieldPlaceholder
        
        searchField.text = viewModel.searchText
        
        searchLanguageSwitch.offLabel.text = viewModel.switchSearchLanguage
        searchLanguageSwitch.onLabel.text = viewModel.switchInterfaceLanguage
        
        searchLanguageSwitch.onThumbImage = UIImage(named: viewModel.switchInterfaceLanguageFlagImage)
        searchLanguageSwitch.offThumbImage = UIImage(named: viewModel.switchLanguageFlagImage)
        
        verbDetailViewController?.updateUI(with: viewModel)
    }
    
    func showVerbNotFoundError(message: String) {
        verbDetailViewController?.showVerbNotFoundError(message: message)
    }
    
    func animateInfinitveAudioButton() {
        verbDetailViewController?.animateInfinitveAudioButton()
    }
    
    func stopAnimatingInfinitiveAudioButton() {
        verbDetailViewController?.stopAnimatingInfinitiveAudioButton()
    }
}

extension ConjugateViewController {
    override func showLoader() {
        verbDetailViewController?.showLoader()
    }
    
    override func hideLoader() {
        verbDetailViewController?.hideLoader()
    }
    
    func show(errorMessage: String) {
        alertHandler?.show(errorMessage: errorMessage)
    }
    
    func hideErrorMessage() {
        verbDetailViewController?.hideErrorMessage()
    }
    
    func show(successMessage: String) {
        alertHandler?.show(succesMessage: successMessage)
    }
}

extension ConjugateViewController {
    func setupTranslationTableView(with searchView: UIView) {
        let defaultHeight: CGFloat = 200
        
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: searchView.frame.width, height: defaultHeight))
        translationTableView = UITableView(frame: frame, style: .plain)
        translationTableView?.layer.cornerRadius = 6
        translationTableView?.layer.borderColor = searchView.layer.borderColor
        translationTableView?.layer.borderWidth = searchView.layer.borderWidth
        
        translationOverlayView = UIView(frame: view.bounds)
        translationOverlayView?.backgroundColor = UIColor.darkGray
        translationOverlayView?.alpha = 0.3
        
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(hideTranslationTableView))
        translationOverlayView?.addGestureRecognizer(tapRec)
    }
    
    func setupTranslationDataSource(for tableView: UITableView) {
        translationDataSource = TranslationDataSource(tableView: tableView)
        translationDataSource?.onTranslationSelected = { [weak self] index in
            self?.translationSelected(index: index)
        }
        
        tableView.dataSource = translationDataSource
        tableView.delegate = translationDataSource
    }
    
    func showTranslationTableView(_ tableView: UITableView, searchView: UIView, overlayView: UIView, dataSource: TranslationDataSource) {
        let yOrigin = searchView.frame.origin.y + searchView.frame.height - 5
        let xOrigin = searchView.frame.origin.x
        
        let origin = CGPoint(x: xOrigin, y: yOrigin)
        let size = CGSize(width: tableView.frame.width, height: 0)
        
        let initialFrame = CGRect(origin: origin, size: size)
        
        let height = heightForTranslationTableView(tableView, dataSource: dataSource)
        let newFrame = CGRect(origin: origin, size: CGSize(width: size.width, height: height))
        
        tableView.frame = initialFrame
        
        overlayView.alpha = 0
        
        view.insertSubview(overlayView, belowSubview: searchView)
        view.insertSubview(tableView, belowSubview: searchView)
        
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 0.3
            tableView.frame = newFrame
        })
    }
    
    func heightForTranslationTableView(_ tableView: UITableView, dataSource: TranslationDataSource) -> CGFloat {
        let expectedHeight = dataSource.contentHeight
        let bottomPadding: CGFloat = 150
        
        //TODO: Get keyboard height dynamically
        let keyboardHeight: CGFloat = 250
        
        let maxHeight = view.frame.height - keyboardHeight - bottomPadding
        
        let height = min(maxHeight, expectedHeight)
        return height
    }
    
    func changeTranslationTableViewHeight(_ tableView: UITableView, dataSource: TranslationDataSource) {
        let height = heightForTranslationTableView(tableView, dataSource: dataSource)
        
        UIView.animate(withDuration: 0.3) {
            tableView.frame.size.height = height
        }
    }
    
    func translationSelected(index: Int) {
        hideTranslationTableView()
        presenter?.translationSelected(at: index)
    }
    
    func hideTranslationTableView() {
        guard let tableView = translationTableView,
            let overlayView = translationOverlayView
            else { return }
        
        var lastFrame = tableView.frame
        lastFrame.size.height = 0
        
        let overlayAlpha: CGFloat = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            tableView.frame = lastFrame
            overlayView.alpha = overlayAlpha
        }) { _ in
            tableView.removeFromSuperview()
            overlayView.removeFromSuperview()
            
            self.translationTableView = nil
            self.translationOverlayView = nil
        }
    }
}

extension ConjugateViewController {
    func showActionsForForm(inTab tab: Int, atTense tense: Int,  at index: Int) {
        verbDetailViewController?.showActionsForForm(inTab: tab, atTense: tense, at: index)
    }
}

extension ConjugateViewController {    
    func textFieldDidChange(_ textField: UITextField) {
        hideErrorMessage()
        
        guard let text = textField.text
            else {
                searchText = textField.text ?? ""
                return
        }
        
        searchText = text
        
        presenter?.userDidInput(searchText: searchText)
    }
    
    func clearSearchTimer() {
        searchTimer?.invalidate()
        searchTimer = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        clearSearchTimer()
        presenter?.userDidTapSearchButton()
        view.endEditing(true)
        return true
    }
}
