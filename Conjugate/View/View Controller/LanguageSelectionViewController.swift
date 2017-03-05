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
    
    var dataSource: LanguageSelectionDataSource?
    
    var presenter: LanguageSelectionPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.getLanguages()
    }
    
    override func setupUI() {
        super.setupUI()
        dataSource = LanguageSelectionDataSource(tableView: tableView)
    }
    
    func render(with viewModel: LanguageSelectionViewModel) {
        title = viewModel.title
        dataSource?.updateUI(with: viewModel.languages)
    }
}

class LanguageSelectionDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    let tableView: UITableView
    
    var languages: [LanguageViewModel] = []
    
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
}
