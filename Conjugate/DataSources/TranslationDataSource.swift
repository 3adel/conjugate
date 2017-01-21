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
    
    let cellHeight: CGFloat = 50
    
    var translations = [TranslationViewModel]()
    
    var onTranslationSelected: ((_: Int) -> ())?
    
    var contentHeight: CGFloat {
        get {
            return cellHeight * CGFloat(translations.count)
        }
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
        
        let cellNib = UINib(nibName: TranslationCell.Nib, bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: TranslationCell.Identifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return translations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TranslationCell.Identifier) as? TranslationCell
            else {
                return UITableViewCell()
        }
        
        cell.update(with: translations[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onTranslationSelected?(indexPath.row)
    }
    
}


