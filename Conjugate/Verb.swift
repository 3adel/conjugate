//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

typealias Tenses = [Verb.TenseGroup: [Tense]]

struct Verb {
    enum TenseGroup: String {
        case indicative
        case conditional
        case imperative
        case conjunctive
        
        static let allCases: [TenseGroup] = [
            .indicative,
            .conjunctive,
            .conditional,
            .imperative
        ]
    }

    let name: String
    let translations: [String]?
    let tenses: Tenses
    
    init(name: String, translations: [String]? = nil, tenses: Tenses = Tenses()) {
        self.name = name
        self.translations = translations
        self.tenses = tenses
    }
}

struct Tense {
    enum Name: String {
        case present
        case past
        case future
        case perfect
        case noTense = ""
        
        static let allTenses: [Tense.Name] = [
            .present,
            .perfect,
            .past,
            .future,
            .noTense
        ]
    }
    
    let name: Name
    let forms: [Form]
}

struct Form {
    let pronoun: String
    let irregular: Bool
    let conjugatedVerb: String
}



