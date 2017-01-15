//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

protocol DictConvertible {
    
    static func from(dict: JSONDictionary) -> Self?
    func asDict() -> JSONDictionary
}

typealias Tenses = [Verb.TenseGroup: [Tense]]

struct Verb {
    enum TenseGroup: String {
        case indicative
        case conditional
        case imperative
        case subjunctive
        
        var translationKey: String {
            return "mobile.ios.conjugate.tenseGroup."+self.rawValue
        }
        
        var text: String {
            return LocalizedString(translationKey)
        }
        
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
    
    static let nameKey = "name"
    static let translationsKey = "translations"
    static let tensesKey = "tenses"
    
    init(name: String, translations: [String]? = nil, tenses: Tenses = Tenses()) {
        self.name = name
        self.translations = translations
        self.tenses = tenses
    }
}

extension Verb: Equatable {}

func ==(lhs: Verb, rhs: Verb) -> Bool {
    return lhs.name == rhs.name
}

extension Verb: DictConvertible {
    func asDict() -> JSONDictionary {
        var dict = JSONDictionary()
        
        dict[Verb.nameKey] = name
        dict[Verb.translationsKey] = translations
        
        var tensesArray = [String: JSONArray]()
        
        TenseGroup.allCases.forEach { tenseGroup in
            if let tense = tenses[tenseGroup] {
                tensesArray[tenseGroup.rawValue] = tense.map { $0.asDict() }
            }
        }
        
        dict[Verb.tensesKey] = tensesArray
        
        return dict
    }

    static func from(dict: JSONDictionary) -> Verb? {
        guard let name = dict[Verb.nameKey] as? String,
            let translations = dict[Verb.translationsKey] as? [String]?,
            let tenseArray = dict[Verb.tensesKey] as? [String: JSONArray]
            else { return nil }
        
        var tenses = Tenses()
        TenseGroup.allCases.forEach { tenseGroup in
            if let tense = tenseArray[tenseGroup.rawValue] {
                tenses[tenseGroup] = tense.flatMap {
                    guard let dict = $0 as? JSONDictionary else { return nil }
                    return Tense.from(dict: dict)
                }
            }
        }
        return self.init(name: name, translations: translations, tenses: tenses)
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
        
        var translationKey: String {
            return "mobile.ios.conjugate.tense."+rawValue
        }
        
        var text: String {
            switch self {
            case .subjunctivePastPerfect:
                return Name.pastPerfect.text
            case .subjunctivePresentPerfect:
                return Name.presentPerfect.text
            case .noTense:
                return rawValue
            default:
                return LocalizedString(translationKey)
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
    
    static let nameKey = "name"
    static let formsKey = "forms"
    
    let name: Name
    let forms: [Form]
}

extension Tense: DictConvertible {
    func asDict() -> JSONDictionary {
        var dict = JSONDictionary()
        
        dict[Tense.nameKey] = name.rawValue
        dict[Tense.formsKey] = forms.map { $0.asDict() }
        
        return dict
    }
    
    static func from(dict: JSONDictionary) -> Tense? {
        guard let nameString = dict[Tense.nameKey] as? String,
            let name = Tense.Name(rawValue: nameString),
            let formsArray = dict[Tense.formsKey] as? [JSONDictionary]
            else { return nil }
        
        let forms = formsArray.flatMap { Form.from(dict: $0) }
        
        return self.init(name: name, forms: forms)
    }
}

struct Form {
    enum FormType: Int {
        case regular, accepted, irregular
    }
    
    let pronoun: String
    let type: FormType
    let conjugatedVerb: String
    
    static let pronounKey = "pronoun"
    static let irregularKey = "irregular"
    static let typeKey = "type"
    static let verbKey = "verb"
}

extension Form: DictConvertible {
    func asDict() -> JSONDictionary {
        var dict = JSONDictionary()
        
        dict[Form.pronounKey] = pronoun
        dict[Form.typeKey] = type.rawValue
        dict[Form.verbKey] = conjugatedVerb
        
        return dict
    }

    static func from(dict: JSONDictionary) -> Form? {
        guard let pronoun = dict[Form.pronounKey] as? String,
            let conjugateVerb = dict[Form.verbKey] as? String
        else { return nil }
        
        var type: FormType!
        
        if let typeRawValue = dict[Form.typeKey] as? Int {
            type = FormType(rawValue: typeRawValue)
        } else if let irregular = dict[Form.irregularKey] as? Bool {
            type = irregular ? FormType.irregular : FormType.regular
        }
        
        return self.init(pronoun: pronoun, type: type, conjugatedVerb: conjugateVerb)
    }
}


