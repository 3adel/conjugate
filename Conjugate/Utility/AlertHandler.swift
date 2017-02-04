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

class AlertHandler {
    let view: UIView
    
    required init(view: UIView, topLayoutGuide: UILayoutSupport? = nil, bottomLayoutGuide: UILayoutSupport? = nil) {
        self.view = view
        setupDodo(topLayoutGuide, bottomLayoutGuide: bottomLayoutGuide)
    }
    
    func setupDodo(_ topLayoutGuide: UILayoutSupport?, bottomLayoutGuide: UILayoutSupport?) {
        view.dodo.style.bar.cornerRadius = 0
        view.dodo.style.bar.animationShow = DodoAnimations.slideVertically.show
        view.dodo.style.bar.animationHide = DodoAnimations.slideVertically.hide
        view.dodo.style.bar.hideOnTap = true
        
        view.dodo.bottomLayoutGuide = bottomLayoutGuide
        view.dodo.topLayoutGuide = topLayoutGuide
    
    }
    
    func show(errorMessage: String) {
        view.dodo.error(errorMessage)
        autoHide()
    }
    
    func show(succesMessage: String) {
        view.dodo.success(succesMessage)
        autoHide()
    }
    
    func styleBarForSuccess() {
        view.dodo.style.bar.backgroundColor = DodoColor.fromHexString("#03C03C")
    }
    
    func styleBarForError() {
        view.dodo.style.bar.backgroundColor = DodoColor.fromHexString("#ED2939")
    }
    
    func autoHide() {
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hide), userInfo: nil, repeats: false)
    }
    
    @objc func hide() {
        view.dodo.hide()
    }
}
