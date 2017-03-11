//
//  SavedVerbDataSource.swift
//  Conjugate
//
//  Created by Halil Gursoy on 11/03/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit


class SavedVerbDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    let tableView: UITableView
    let verbs: [SavedVerbCellViewModel]
    
    var onVerbDidSelect: ((Int) -> ())?
    var onVerbShouldDelete: ((Int) -> ())?
    
    init(tableView: UITableView, verbs: [SavedVerbCellViewModel], onVerbDidSelect: ((Int) -> ())? = nil, onVerbShouldDelete: ((Int) -> ())? = nil) {
        self.tableView = tableView
        self.verbs = verbs
        self.onVerbDidSelect = onVerbDidSelect
        self.onVerbShouldDelete = onVerbShouldDelete
        
        super.init()
        registerNib()
    }
    
    func registerNib() {
        let cellNib = UINib(nibName: SavedVerbCell.Nib, bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: SavedVerbCell.Identifier)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verbs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedVerbCell") as? SavedVerbCell else { return UITableViewCell() }
        
        let cellViewModel = verbs[indexPath.row]
        cell.update(with: cellViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onVerbDidSelect?(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            onVerbShouldDelete?(indexPath.row)
        }
    }

}

