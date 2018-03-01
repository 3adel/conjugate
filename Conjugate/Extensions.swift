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
            return UIColor(red: 74, green: 144, blue: 226)
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

public enum LabelType: Int {
    case regular
    case error
    
    public var textColor: UIColor {
        switch(self) {
        case .regular:
            return UIColor.black
        case .error:
            return UIColor(red: 209, green: 51, blue: 51)
        }
    }
}

public struct Theme {
    static let mainTintColor = UIColor(red: 74, green: 144, blue: 226)
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
    
    func set(labelType: LabelType) {
        textColor = labelType.textColor
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
    @objc
    func showLoader() {
        
    }
    
    @objc
    func hideLoader() {
        
    }
    
    @objc
    func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
    }
    
    @objc
    func setupTabBar(shouldShow: Bool) {
        let bottomPoint = view.frame.height
        let yPoint = shouldShow ? bottomPoint - (tabBarController?.tabBar.frame.height)! : bottomPoint
        
        UIView.animate(withDuration: 0.3) {
            var frame = self.tabBarController!.tabBar.frame
            frame.origin.y = yPoint
            
            self.tabBarController?.tabBar.frame = frame
            self.tabBarController?.tabBar.isHidden = !shouldShow
        }
    }
}

extension UIViewController: UITextFieldDelegate {
    @objc
    func closeKeyboard() {
        view.endEditing(true)
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
    }
    
    @objc
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(UIViewController.closeKeyboard))
        tapRec.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRec)
        return true
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return boundingBox.width
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
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

extension UIFont {
    var bold: UIFont {
        return with(traits: .traitBold)
    } // bold
    
    var italic: UIFont {
        return with(traits: .traitItalic)
    } // italic
    
    var boldItalic: UIFont {
        return with(traits: [.traitBold, .traitItalic])
    } // boldItalic
    
    
    func with(traits: UIFontDescriptorSymbolicTraits) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
            return self
        } // guard
        
        return UIFont(descriptor: descriptor, size: 0)
    } // with(traits:)
} // extension

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

extension NSMutableAttributedString {
    
    @discardableResult
    public func set(_ text :String, asLink link:String) -> Bool {
        let foundRange = self.mutableString.range(of: text)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: link, range: foundRange)
            return true
        }
        return false
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}


// MARK: - device

public func isPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
}

public func isPhone() -> Bool {
    return (!isPad()) && UIApplication.shared.canOpenURL(URL(string: "tel:123")!)
}

// MARK: - Screen

public func isRetina() -> Bool {
    return UIScreen.main.scale >= 2.0
}

extension UIImage {
    
    func byScaling(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

/**
 UINavigationBar extension for filling empty status bar background
 */

public extension UINavigationBar {
    private struct AssociatedKeys {
        static var backgroundViewName = "conjugate_NavigationBarBackground"
    }
    
    var backgroundView: UIView? {
        get {
            return objc_getAssociatedObject(self,
                                            &AssociatedKeys.backgroundViewName) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.backgroundViewName,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func setBackground(color: UIColor, includingStatusBar: Bool = true) {
        backgroundView?.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        barTintColor = UIColor.clear
        
        if includingStatusBar {
            backgroundView?.isHidden = false
            if backgroundView == nil {
                setupBackgroundView()
            }
            backgroundView?.backgroundColor = color
        } else {
            backgroundView?.isHidden = true
            backgroundColor = color
        }
    }
    
    private func setupBackgroundView() {
        var backgroundFrame = bounds
        backgroundFrame.origin.y = -20
        backgroundFrame.size.height = 64
        
        backgroundView = UIView(frame: backgroundFrame)
        backgroundView?.isUserInteractionEnabled = false
        
        insertSubview(backgroundView!, at: 0)
    }
}

public extension UIViewController {
    private struct AssociatedKeys {
        static var statusBarBackgroundView = "conjugate_StatusBarBackground"
    }
    
    var statusBarBackgroundView: UIView? {
        get {
            return objc_getAssociatedObject(self,
                                            &AssociatedKeys.statusBarBackgroundView) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.statusBarBackgroundView,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func setStatusBar(backgroundColor: UIColor) {
        if statusBarBackgroundView == nil {
            setupBackgroundView()
        }
        statusBarBackgroundView?.backgroundColor = backgroundColor
    }
    
    private func setupBackgroundView() {
        let backgroundFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 20)
        
        statusBarBackgroundView = UIView(frame: backgroundFrame)
        statusBarBackgroundView?.isUserInteractionEnabled = false
        
        view.insertSubview(statusBarBackgroundView!, at: 0)
    }

}

