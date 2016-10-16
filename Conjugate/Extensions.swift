//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

public enum ButtonType: Int {
    case regular
    case mainTint
    
    public var backgroundColor: UIColor {
        switch(self) {
        case .regular:
            return UIColor(red: 216, green: 216, blue: 216)
        case .mainTint:
            return Theme.mainTintColor
        }
    }
    
    public var textColor: UIColor {
        switch(self) {
        case.regular:
            return UIColor(red: 74, green: 74, blue: 74)
        case .mainTint:
            return UIColor.white
        }
    }
    
    public var cornerRadius: Float {
        return 4
    }
}

public struct Theme {
    static let mainTintColor = UIColor(red: 207, green: 69, blue: 85)
}

extension UIImageView {
    func addOverlay(withColor color: UIColor, alpha: Float) {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        view.backgroundColor = color
        view.alpha = CGFloat(alpha)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
}

extension UIButton {
    func set(buttonType: ButtonType) {
        backgroundColor = buttonType.backgroundColor
        setTitleColor(buttonType.textColor, for: .normal)
        
        layer.cornerRadius = CGFloat(buttonType.cornerRadius)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
}

extension UIViewController {
    func showLoader() {
        
    }
    
    func hideLoader() {
        
    }
    
    func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
    }
}

extension UIViewController: UITextFieldDelegate {
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(UIViewController.closeKeyboard))
        view.addGestureRecognizer(tapRec)
        return true
    }
}
