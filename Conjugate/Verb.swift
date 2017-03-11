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
        case nominal
        
        var translationKey: String {
            return "mobile.ios.conjugate.tenseGroup."+self.rawValue
        }
        
        var text: String {
            return LocalizedString(translationKey, languageType: .conjugationLanguage)
        }
        
        var ids: [String] {
            switch self {
            case .nominal:
                return ["2","10","21"]
            default:
                return []
            }
        }
        
        static let allCases: [TenseGroup] = [
            .indicative,
            .subjunctive,
            .conditional,
            .imperative
        ]
    }

    let name: String
    let language: Language
    let translations: [String]?
    let tenses: Tenses
    let nominalForms: [String]
    
    // User defaults keys as static constants are deprecated
    static let nameKey = "name"
    static let translationsKey = "translations"
    static let tensesKey = "tenses"
    static let nominalFormKey = "nomialForm"
    
    enum UserDefaultKey: String, DictionaryKey {
        case name
        case translation
        case tenses
        case nominalForm
        case language
    }
    
    init(name: String, language: Language, translations: [String]? = nil, tenses: Tenses = Tenses(), nominalForms: [String] = []) {
        self.name = name
        self.language = language
        self.translations = translations
        self.tenses = tenses
        self.nominalForms = nominalForms
    }
}

extension Verb: Equatable {}

func ==(lhs: Verb, rhs: Verb) -> Bool {
    return lhs.name == rhs.name
}

extension Verb: DictConvertible {
    func asDict() -> JSONDictionary {
        var dict = JSONDictionary()
        
        dict[UserDefaultKey.name.key] = name
        dict[UserDefaultKey.nominalForm.key] = nominalForms
        dict[UserDefaultKey.translation.key] = translations
        
        var tensesArray = [String: JSONArray]()
        
        TenseGroup.allCases.forEach { tenseGroup in
            if let tense = tenses[tenseGroup] {
                tensesArray[tenseGroup.rawValue] = tense.map { $0.asDict() }
            }
        }
        
        dict[UserDefaultKey.tenses.key] = tensesArray
        dict[UserDefaultKey.language.key] = language.localeIdentifier
        
        return dict
    }

    static func from(dict: JSONDictionary) -> Verb? {
        guard let name = dict[UserDefaultKey.name.key] as? String ?? dict[Verb.nameKey] as? String,
            let translations = dict[UserDefaultKey.translation.key] as? [String]? ?? dict[Verb.translationsKey] as? [String]?,
        let tenseArray = dict[UserDefaultKey.tenses.key] as? [String: JSONArray] ?? dict[Verb.tensesKey] as? [String: JSONArray]
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
        
        let nominalForms = (dict[UserDefaultKey.nominalForm.key] as? [String] ?? dict[Verb.nominalFormKey] as? [String]) ?? [String]()
        
        let languageIdentifier = dict[UserDefaultKey.language.key] as? String ?? ""
        
        // Language was introduced in v1.2. Before this the only available conjugation language was German. So if the language doesn't exist in the storage, this verb was German
        let language = Language(localeIdentifier: languageIdentifier) ?? .german
        
        return self.init(name: name, language: language, translations: translations, tenses: tenses, nominalForms: nominalForms)
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
        case preterite
        case preterite2
        case subjunctiveFuture
        case subjunctiveFuture2
        
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
            case .subjunctiveFuture:
                return Name.future.text
            case .subjunctiveFuture2:
                return Name.future2.text
            case .noTense:
                return rawValue
            default:
                return LocalizedString(translationKey, languageType: .conjugationLanguage)
            }
        }
        
        private static let germanTenses: [Tense.Name] = [
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
        
        private static let spanishTenses: [Tense.Name] = [
            .present,
            .past,
            .presentPerfect,
            .subjunctivePresentPerfect,
            .pastPerfect,
            .subjunctivePastPerfect,
            .preterite,
            .preterite2,
            .future,
            .future2,
            .subjunctiveFuture,
            .subjunctiveFuture2,
            .conditionalPast,
            .conditionalPastPerfect,
            .noTense

        ]
        
        static func getTenses(for language: Language) -> [Tense.Name] {
            switch language {
            case .german:
                return germanTenses
            case .spanish:
                return spanishTenses
            default:
                return []
            }
        }
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


