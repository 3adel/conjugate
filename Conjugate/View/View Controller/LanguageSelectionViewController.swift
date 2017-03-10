//
//  LanguageSelectionViewController.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

class LanguageSelectionViewController: UIViewController, LanguageSelectionView {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    
    var dataSource: LanguageSelectionDataSource?
    
    var presenter: LanguageSelectionPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.getLanguages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar(shouldShow: false)
    }
    
    override func setupUI() {
        super.setupUI()
        applyButton.setTitle(LocalizedString("languageSelection.apply"), for: .normal)
        
        dataSource = LanguageSelectionDataSource(tableView: tableView)
        
        dataSource?.didSelectLanguage = { [weak self] index in
            self?.presenter?.didSelectLanguage(at: index)
        }
    }
    
    func render(with viewModel: LanguageSelectionViewModel) {
        title = viewModel.title
        
        UIView.animate(withDuration: 0.3) {
            self.applyButton.backgroundColor = UIColor(red: viewModel.applyButtonBackgroundColor.0/255,
                                                  green: viewModel.applyButtonBackgroundColor.1/255,
                                                  blue: viewModel.applyButtonBackgroundColor.2/255,
                                                  alpha: 1.0)
        }
        
        applyButton.isEnabled = viewModel.applyButtonIsEnabled
        
        dataSource?.updateUI(with: viewModel.languages)
    }
    
    @IBAction func didPressApplyButton(_ sender: UIButton) {
        presenter?.didPressApplyButton()
    }
}

class LanguageSelectionDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    let tableView: UITableView
    
    var languages: [LanguageViewModel] = []
    
    var didSelectLanguage: ((Int) -> ())?
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func updateUI(with languages: [LanguageViewModel]) {
        self.languages = languages
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LanguageCell.Identifier) as? LanguageCell else { return UITableViewCell() }
        
        let viewModel = languages[indexPath.row]
        
        cell.update(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectLanguage?(indexPath.row)
    }
}
