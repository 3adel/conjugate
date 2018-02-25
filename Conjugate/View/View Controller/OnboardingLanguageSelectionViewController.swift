//
//  OnboardingLanguageSelectionViewController.swift
//  Conjugate
//
//  Created by Halil Gursoy on 12/03/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

class OnboardingLanguageSelectionViewController: UIViewController, OnboardingViewType {
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var introTextLabel: UILabel!
    @IBOutlet weak var languageSelectionView: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var alignCenterConstraint: NSLayoutConstraint!
    
    let topMarging: CGFloat = 50
    
    let languageSelectionSegueIdentifier = "languageSelectionSegue"
    
    var languageSelectionViewController: LanguageSelectionViewController?
    
    var presenter: OnboardingPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.getInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doInitialAnimation()
    }
    
    override func setupUI() {
        view.backgroundColor = UIColor.white //UIColor.groupTableViewBackground
        topConstraint.priority = .defaultLow
        alignCenterConstraint.priority = .defaultHigh
        
        logoLabel.font = UIFont.systemFont(ofSize: 54)
        
        contentTopConstraint.constant = 500
        bottomConstraint.constant = -500 + 32
        
    }
    
    func doInitialAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = UIColor.groupTableViewBackground
            self.topConstraint.priority = .defaultHigh
            self.alignCenterConstraint.priority = .defaultLow
            
            self.logoLabel.font = UIFont.systemFont(ofSize: 36)
            
            self.contentTopConstraint.constant = 32
            self.bottomConstraint.constant = 0
            
            self.view.layoutIfNeeded()
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == languageSelectionSegueIdentifier {
            guard let vc = segue.destination as? LanguageSelectionViewController else { return }
            vc.presenter = presenter
            
            languageSelectionViewController = vc
        }
    }
    
    func render(with viewModel: OnboardingViewModel) {
        introTextLabel.text = viewModel.descriptionText
        
        languageSelectionViewController?.render(with: viewModel.languageSelectionViewModel)
    }
}
