//
//  DerSatzPromotionCell.swift
//  Conjugate
//
//  Created by Halil Gursoy on 28.02.18.
//  Copyright © 2018 Adel  Shehadeh. All rights reserved.
//

import UIKit

class DerSatzPromotionCell: UITableViewCell {
    
    var onDismissButtonTap: (() -> Void)?
    var onInstallNowTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBAction
    func didTapDismissButton() {
        onDismissButtonTap?()
    }
    
    @IBAction
    func didTapInstallNowButton() {
        onInstallNowTap?()
    }
    
    private func setupUI() {
        selectionStyle = .none
    }
}
