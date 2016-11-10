//
//  ShareController.swift
//  Conjugate
//
//  Created by Halil Gursoy on 09/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation


class ShareController {
    
    let router: Router?
    
    init(view: View) {
        router = Router(view: view)
    }
    
    func shareApp() {
        let textToShare = "Easy German verbs conjugation with konj.me. Download for iOS now at "
        let urlStringToShare = "http://www.konj.me"
        
        share(text: textToShare, url: urlStringToShare)
    }
    
    func share(verb: Verb) {
        guard let presentTenseForms = verb.tenses[.indicative]?.filter({ $0.name == .present }).first?.forms else { return }
        
        var textToShare = "Präsens conjugations of the verb \(verb.name):" + "\n\n"
        for form in presentTenseForms {
            textToShare += "\(form.pronoun) \(form.conjugatedVerb)" + "\n"
        }
        
        textToShare += "\nVia konj.me app for iOS. Download here "
        let urlStringToShare = "http://www.konj.me"
        share(text: textToShare, url: urlStringToShare)
    }
    
    func share(text: String, url: String) {
        let objectToShare = [text, url]
        let activityVC = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        
        router?.show(viewController: activityVC)
    }
}
