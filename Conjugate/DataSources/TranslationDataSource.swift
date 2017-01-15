//
//  TranslationDataSource.swift
//  Conjugate
//
//  Created by Halil on 15/01/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

class TranslationDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    let tableView: UITableView
    let cellIdentifier = "TranslationCell"
    
    let cellHeight: CGFloat = 50
    
    var translations = [String]()
    
    var onTranslationSelected: ((_: Int) -> ())?
    
    var contentHeight: CGFloat {
        get {
            return cellHeight * CGFloat(translations.count)
        }
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    func setup(_ cell: UITableViewCell) {
        cell.accessoryType = .disclosureIndicator
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return translations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            else {
                return UITableViewCell()
        }
        
        setup(cell)
        
        cell.textLabel?.text = translations[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onTranslationSelected?(indexPath.row)
    }
}


