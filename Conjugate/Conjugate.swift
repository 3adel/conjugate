//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit


class ConjugateViewController: UIViewController {
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchField: FlexLanguageTextField!
    @IBOutlet var searchLanguageSwitch: SevenSwitch!
    
    let verbDetailSegue = "verbDetailSegue"
    
    var loadingView: LoadingView?
    var alertHandler: AlertHandler?
    
    var presenter: ConjugatePresnterType!
    var verbDetailViewController: VerbDetailViewController?
    
    var searchTimer: Timer?
    
    var viewModel = ConjugateViewModel.empty
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPresenter()
        
        updateUI(with: viewModel)
        
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
        presenter.updateViewModel()
    }
    
    override func setupUI() {
        super.setupUI()
        
        searchField.locale = "de_DE"
        
        navigationController?.isNavigationBarHidden = true
        
        searchView.layer.cornerRadius = 4
        searchView.layer.borderWidth = 1
        
        searchField.delegate = self
        
        let grayColor: CGFloat = 230/255.0
        searchView.layer.borderColor = UIColor(red: grayColor, green: grayColor, blue: grayColor, alpha: 1.0).cgColor
        
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        alertHandler = AlertHandler(view: view, topLayoutGuide: topLayoutGuide, bottomLayoutGuide: bottomLayoutGuide)
        
        searchLanguageSwitch.offLabel.text = "DE"
        searchLanguageSwitch.onLabel.text = "EN"
        
        searchLanguageSwitch.onThumbImage = UIImage(named: "en_flag")
        searchLanguageSwitch.offThumbImage = UIImage(named: "de_flag")
    }
    
    func search() {
        let minNumOfCharacters = 2
        if searchText.characters.count >= minNumOfCharacters {
            presenter.search(for: searchText.lowercased())
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
    
    private func setupPresenter() {
        presenter = ConjugatePresenter(view: self)
        verbDetailViewController?.presenter = presenter
    }
}

extension ConjugateViewController: ConjugateView {
    func updateUI(with viewModel: ConjugateViewModel) {
        self.viewModel = viewModel
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
        let minNumOfCharacters = 2
        
        if text.characters.count >= minNumOfCharacters {
            clearSearchTimer()
            searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(search), userInfo: nil, repeats: false)

        }
    }
    
    func clearSearchTimer() {
        searchTimer?.invalidate()
        searchTimer = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        clearSearchTimer()
        search()
        view.endEditing(true)
        return true
    }
}
