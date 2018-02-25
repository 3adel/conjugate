//
//  Swift.swift
//  Conjugate
//
//  Created by Halil Gursoy on 02/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit


class AnimatedButton: UIButton {
    var images = [UIImage]()
    var defaultImage: UIImage?
    var animateImageIndex = 0
    var animationInterval: TimeInterval = 0.3
    
    private var timer: Timer?
    
    func startAnimating() {
        defaultImage = image(for: .normal)
        setImage(images.first, for: .normal)
        animateImageIndex = 0
        timer = Timer.scheduledTimer(timeInterval: animationInterval, target: self, selector: #selector(changeToNextImage), userInfo: nil, repeats: true)
    }
    
    func stopAnimating() {
        timer?.invalidate()
        timer = nil
        setImage(defaultImage, for: .normal)
    }
    
    @objc
    func changeToNextImage() {
        if animateImageIndex >= images.count {
            animateImageIndex = 0
        }
        setImage(images[animateImageIndex], for: .normal)
        animateImageIndex += 1
    }
    
}
