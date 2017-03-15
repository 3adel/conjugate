//
//  SavedVerbCell.swift
//  Conjugate
//
//  Created by Halil Gursoy on 11/03/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

class SavedVerbCell: UITableViewCell {
    func update(with viewModel: SavedVerbCellViewModel) {
        textLabel?.text = viewModel.verb
        detailTextLabel?.text = viewModel.meaning
    }
}
