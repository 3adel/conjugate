//
//  MoreViewController.swift
//  Conjugate
//
//  Created by Halil Gursoy on 06/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController, SettingsView {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var footerLabel: UILabel!
    
    var dataSource: SettingsDataSource?
    var presenter: SettingsPresenter!
    
    override func viewDidLoad() {
        setupUI()
        presenter.getOptions()
    }
    
    override func setupUI() {
        setupPresenter()
        setupCollectionView()
    }
    
    func setupPresenter() {
        presenter = SettingsPresenter(view: self)
    }
    
    func setupCollectionView() {
        dataSource = SettingsDataSource(tableView: tableView, presenter: presenter)
    }
    
    func render(with viewModel: SettingsViewModel) {
        footerLabel.text = viewModel.footerTitle
        dataSource?.render(with: viewModel.options)
    }
}


class SettingsDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    let tableView: UITableView
    
    var options = [String]()
    
    let presenter: SettingsPresenter
    
    init(tableView: UITableView, presenter: SettingsPresenter) {
        self.tableView = tableView
        self.presenter = presenter
        super.init()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    func render(with options: [String]) {
        self.options = options
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.optionSelected(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") else { return UITableViewCell() }
        
        let settingsTitle = options[indexPath.row]
        
        cell.textLabel?.text = settingsTitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
