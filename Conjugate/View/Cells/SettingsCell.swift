//
//  SettingsCell.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

class SettingsOptionCell: UITableViewCell {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func update(with viewModel: SettingsOptionViewModel) {
        titleLabel.text = viewModel.title
        leftImageView.image = UIImage(named: viewModel.imageName)
    }
}

class SettingsLanguageCell: UITableViewCell {
    @IBOutlet weak var languageImageView: UIImageView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    func update(with viewModel: SettingsLanguageViewModel) {
        titleLabel.text = viewModel.title
        languageLabel.text = viewModel.languageName
        languageImageView.image = UIImage(named: viewModel.languageImageName)
    }
}
