//
//  SettingsCell.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    func update(with viewModel: SettingsOptionViewModel) {
        self.titleLabel.text = viewModel.title
        self.leftImageView.image = UIImage(named: viewModel.imageName)
    }
}
