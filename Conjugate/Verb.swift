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
        case subjunctive
        
        static let allCases: [TenseGroup] = [
            .indicative,
            .subjunctive,
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
        case future2
        case presentPerfect
        case pastPerfect
        case conditionalPast
        case conditionalPastPerfect
        case subjunctivePresentPerfect
        case subjunctivePastPerfect
        
        case noTense = ""
        
        var text: String {
            switch self {
            case .present:
                return "Simple Present"
            case .past:
                return "Simple Past"
            case .future:
                return "Future 1"
            case .future2:
                return "Future 2"
            case .presentPerfect:
                return "Present Perfect"
            case .pastPerfect:
                return "Past Perfect"
            case .conditionalPast:
                return "Past (würde)"
            case .conditionalPastPerfect:
                return "Past Perfect (würde)"
            case .subjunctivePastPerfect:
                return Name.pastPerfect.text
            case .subjunctivePresentPerfect:
                return Name.pastPerfect.text
            default:
                return self.rawValue
            }
        }
        
        static let allTenses: [Tense.Name] = [
            .present,
            .past,
            .presentPerfect,
            .subjunctivePresentPerfect,
            .pastPerfect,
            .subjunctivePastPerfect,
            .future,
            .future2,
            .conditionalPast,
            .conditionalPastPerfect,
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



