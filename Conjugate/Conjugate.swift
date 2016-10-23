//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit


class ConjugateViewController: UIViewController {
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchField: UITextField!
    
    let verbDetailSegue = "verbDetailSegue"
    
    var loadingView: LoadingView?
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.updateViewModel()
    }
    
    override func setupUI() {
        super.setupUI()
        
        navigationController?.isNavigationBarHidden = true
        
        searchView.layer.cornerRadius = 4
        searchView.layer.borderWidth = 1
        
        searchField.delegate = self
        
        let grayColor: CGFloat = 230/255.0
        searchView.layer.borderColor = UIColor(red: grayColor, green: grayColor, blue: grayColor, alpha: 1.0).cgColor
        
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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

//Actions
extension ConjugateViewController {
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        presenter.toggleSavingVerb()
    }
}

extension ConjugateViewController: ConjugateView {
    func updateUI(with viewModel: ConjugateViewModel) {
        self.viewModel = viewModel
        verbDetailViewController?.updateUI(with: viewModel)
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
        verbDetailViewController?.show(errorMessage: errorMessage)
    }
    
    func hideErrorMessage() {
        verbDetailViewController?.hideErrorMessage()
    }
}

extension ConjugateViewController {
    func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text,
            text.characters.count > searchText.characters.count //Search should only be done if the user is entering characters, not when deleting them
            else {
                searchText = textField.text ?? ""
                return
        }
        
        searchText = text
        let minNumOfCharacters = 2
        
        if text.characters.count >= minNumOfCharacters {
            searchTimer?.invalidate()
            searchTimer = nil
            
            searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(search), userInfo: nil, repeats: false)

        }
    }

    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        view.endEditing(true)
        return true
    }
}
