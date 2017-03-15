//
//  LanguageCell.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

class LanguageCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    func update(with viewModel: LanguageViewModel) {
        titleLabel.text = viewModel.title
        flagImageView.image = UIImage(named: viewModel.imageName)
        
        selectedImageView.isHidden = !viewModel.isSelected
        
        accessoryType = .none
        selectionStyle = .none
    }
}
