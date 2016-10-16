//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit


class ConjugateViewController: UIViewController {
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var verbLabel: UILabel!
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var meaningLabel: UILabel!
    
    var presenter: ConjugatePresnterType!
    
    var searchTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPresenter()
    }
    
    override func setupUI() {
        super.setupUI()
        
        navigationController?.isNavigationBarHidden = true
        
        searchView.layer.cornerRadius = 4
        searchView.layer.borderWidth = 1
        
        let grayColor: CGFloat = 230/255.0
        searchView.layer.borderColor = UIColor(red: grayColor, green: grayColor, blue: grayColor, alpha: 1.0).cgColor
    }
    
    func search() {
        let text = searchField.text ?? ""
        presenter.search(for: text)
    }
    
    private func setupPresenter() {
        presenter = ConjugatePresenter(view: self)
    }
}

extension ConjugateViewController: ConjugateView {
    func updateUI(with viewModel: ConjugateViewModel) {
        verbLabel.text = viewModel.verb
        languageLabel.text = viewModel.language
    }
}

extension ConjugateViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchTimer?.invalidate()
        searchTimer = nil
        
        searchTimer = Timer(timeInterval: 2, target: self, selector: #selector(search), userInfo: nil, repeats: false)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        return true
    }
}
