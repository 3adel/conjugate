//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    enum Style: Int {
        case system
        case custom
    }
    
    private let activityIndicator: UIActivityIndicatorView
    private let style: Style
    
    class func showIn(view: UIView, withFrame rect: CGRect) -> LoadingView {
        let loadingView = LoadingView(style: .system)
        loadingView.frame = rect
        
        view.addSubview(loadingView)
        
        loadingView.activityIndicator.startAnimating()
        
        return loadingView
    }
    
    init(style: Style) {
        self.style = style
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        super.init(frame: CGRect.zero)
        
        addSubview(activityIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.style = .system
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
       
        super.init(frame: CGRect.zero)
        
        addSubview(activityIndicator)
    }
    
    func stop() {
        removeFromSuperview()
    }
    
}
