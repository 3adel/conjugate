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
    
    var textWidth: CGFloat {
         return titleLabel?.textWidth ?? 0
    }
}

extension UILabel {
    var textWidth: CGFloat {
       return text?.widthWithConstrainedHeight(height: frame.height, font: font ?? UIFont.systemFont(ofSize: 13)) ?? 0
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

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
}

extension NSAttributedString {
    func heightWithConstrainedWidth(width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
}

extension CGRect {
    var right: CGFloat {
        return origin.x + width
    }
    
    var bottom: CGFloat {
        return origin.y + height
    }
    
    var center: CGPoint {
        get {
            return CGPoint(x: centerX, y: centerY)
        }
        set(value) {
            centerX = value.x
            centerY = value.y
        }
    }
    
    var centerX: CGFloat {
        get {
            return width/2
        }
        set(value) {
            origin.x = value - width/2
        }
    }
    var centerY: CGFloat {
        get {
            return height/2
        }
        set(value) {
            origin.y = value - height/2
        }
    }
}