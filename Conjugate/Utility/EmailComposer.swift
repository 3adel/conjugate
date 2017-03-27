//
//  EmailComposer.swift
//  Conjugate
//
//  Created by Halil Gursoy on 09/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import MessageUI


class EmailComposer: NSObject {
    
    let router: Router?
    
    init(view: View) {
        router = Router(view: view)
    }
    
    func sendEmail(withSubject subject: String, recipient: String, version: String, build: String) {
        guard MFMailComposeViewController.canSendMail()
            else {
                
                let alertController = UIAlertController(title: nil, message: LocalizedString("mobile.ios.conjugate.error.noEmailSetup"), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.router?.dismiss()
                }))
                
                router?.show(viewController: alertController)
                return
        }
        
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        
        mailVC.setToRecipients([recipient])
        mailVC.setSubject(subject)
        
        if let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String),
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
            let messageBody = "\n\n\n\n\n" + "‾‾‾‾‾\n" +
                "App Version: \(version)\n" +
            "Build: \(build)\n"

            mailVC.setMessageBody(messageBody, isHTML: false)
        }
        router?.show(viewController: mailVC)
    }
}


extension EmailComposer: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult, error: Error?) {
        router?.dismissModal()
    }
}
