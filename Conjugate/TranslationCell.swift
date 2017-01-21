//
//  TranslationCell.swift
//  Conjugate
//
//  Created by Halil Gursoy on 21/01/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

class TranslationCell: UITableViewCell {
    @IBOutlet weak var verbLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    
    func update(with viewModel: TranslationViewModel) {
        verbLabel.text = viewModel.verb
        meaningLabel.text = viewModel.meaning
    }
}
