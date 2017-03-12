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
    
    let languageSelectionSegueIdentifier = "languageSelectionSegue"
    
    var languageSelectionViewController: LanguageSelectionViewController?
    
    var presenter: OnboardingPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        presenter?.getInitialData()
    }
    
    override func setupUI() {
        view.backgroundColor = UIColor.groupTableViewBackground
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
