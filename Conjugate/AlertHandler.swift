//
//  AlertView.swift
//  Conjugate
//
//  Created by Halil Gursoy on 31/10/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import UIKit
import Dodo

class AlertView {
    let view: UIView
    
    required init(view: UIView, topLayoutGuide: UILayoutSupport? = nil, bottomLayoutGuide: UILayoutSupport? = nil) {
        self.view = view
        setupDodo(topLayoutGuide, bottomLayoutGuide: bottomLayoutGuide)
    }
    
    func setupDodo(_ topLayoutGuide: UILayoutSupport?, bottomLayoutGuide: UILayoutSupport?) {
        view.dodo.style.leftButton.icon = .close
        view.dodo.style.leftButton.onTap = hide
        
        view.dodo.bottomLayoutGuide = bottomLayoutGuide
        view.dodo.topLayoutGuide = topLayoutGuide
    }
    
    func showError(_ message: String) {
        view.dodo.error(message)
        autoHide()
    }
    
    func showSuccess(_ message: String) {
        view.dodo.success(message)
        autoHide()
    }
    
    func autoHide() {
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(hide), userInfo: nil, repeats: false)
    }
    
    @objc func hide() {
        view.dodo.hide()
    }
}
