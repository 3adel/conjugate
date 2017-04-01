//
//  ShareController.swift
//  Conjugate
//
//  Created by Halil Gursoy on 09/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit


class ShareController {
    
    let router: Router?
    unowned let view: View
    
    init(view: View) {
        self.view = view
        router = Router(view: view)
    }
    
    func shareApp(sourceView: View, sourceRect: CGRect? = nil) {
        let textToShare = "Easy verbs conjugation with konj.me. Download for iOS now at "
        let urlStringToShare = "https://goo.gl/0iUTJI"
        
        share(text: textToShare, url: urlStringToShare, sourceView: sourceView, sourceRect: sourceRect)
    }
    
    func share(verb: Verb, sourceView: View, sourceRect: CGRect? = nil) {
        guard let presentTenseForms = verb.tenses[.indicative]?.filter({ $0.verbixID == "0" }).first?.forms else { return }
        
        var textToShare = "Präsens forms of the verb \(verb.name):" + "\n\n"
        for form in presentTenseForms {
            textToShare += "\(form.pronoun) \(form.conjugatedVerb)" + "\n"
        }
        
        textToShare += "\nVia konj.me app "
        let urlStringToShare = "https://goo.gl/0iUTJI"
        share(text: textToShare, url: urlStringToShare, sourceView: sourceView, sourceRect: sourceRect)
    }
    
    func share(text: String, url: String, sourceView: View, sourceRect: CGRect? = nil) {
        let objectToShare = [text, url]
        let activityVC = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)

        router?.present(sheetViewController: activityVC, sourceView: sourceView as? UIView, sourceRect: sourceRect)
    }
}
