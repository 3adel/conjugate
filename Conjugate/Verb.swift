//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

protocol DictConvertible {
    
    static func from(dict: JSONDictionary) -> Self?
    func asDict() -> JSONDictionary
}

typealias Tenses = [TenseGroup: [Tense]]

enum TenseGroup: String {
    case indicative
    case conditional
    case imperative
    case subjunctive
    case inflected
    case nominal
    case progressiveIndicative
    case progressiveConditional
    
    init?(verbixId: String, language: Language) {
        switch verbixId {
        case "0", "2", "10", "12", "4", "14", "5", "9", "15":
            self = .indicative
        case "1", "3", "11", "13", "6", "16":
            self = .subjunctive
        case "7", "17":
            if language == .german {
                self = .subjunctive
            } else {
                self = .conditional
            }
        case "8":
            self = .imperative
        case "41", "42", "43", "44", "45", "46":
            self = .progressiveIndicative
        case "47", "48":
            self = .progressiveConditional
        default:
            return nil
        }
    }
    
    var translationKey: String {
        return "mobile.ios.conjugate.tenseGroup."+self.rawValue
    }
    
    func localizedTitle(in language: Language) -> String {
        return LocalizedString(translationKey, in: language)
    }
    
    var ids: [String] {
        switch self {
        case .nominal:
            return ["2","10","21"]
        default:
            return []
        }
    }
    
    var sortedTenseIDs: [String] {
        switch (self){
        case .indicative:
            return ["0", "2", "10", "12", "4", "14", "5", "9", "15"]
        case .subjunctive:
            return ["1", "3", "11", "13", "6", "16", "7", "17"]
        case .conditional:
            return ["7", "17"]
        case .imperative:
            return ["8"]
        case .inflected:
            return ["18", "28"]
        case .progressiveIndicative:
            return ["41", "43", "42", "44", "45", "46"]
        case .progressiveConditional:
            return ["47", "48"]
        default:
            return []
        }
    }
    
    static let allCases: [TenseGroup] = [
        .indicative,
        .subjunctive,
        .conditional,
        .imperative,
        .progressiveIndicative,
        .progressiveConditional
    ]
}

struct Verb {
    enum UserDefaultsKey: String, DictionaryKey {
        case name
        case language
        case translations
        case tenses
        case nominalForms
    }
    
    let name: String
    let language: Language
    let translations: [String]?
    let tenses: Tenses
    let nominalForms: [String]
    
    static let nameKey = "name"
    static let translationsKey = "translations"
    static let tensesKey = "tenses"
    static let nominalFormKey = "nomialForm"
    
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
        
        dict[UserDefaultsKey.name.key] = name
        dict[UserDefaultsKey.nominalForms.key] = nominalForms
        dict[UserDefaultsKey.translations.key] = translations
        
        var tensesArray = [String: JSONArray]()
        
        TenseGroup.allCases.forEach { tenseGroup in
            if let tense = tenses[tenseGroup] {
                tensesArray[tenseGroup.rawValue] = tense.map { $0.asDict() }
            }
        }
        
        dict[UserDefaultsKey.tenses.key] = tensesArray
        dict[UserDefaultsKey.language.key] = language.localeIdentifier
        
        return dict
    }

    static func from(dict: JSONDictionary) -> Verb? {
        guard let name = dict[UserDefaultsKey.name.key] as? String ?? dict[Verb.nameKey] as? String,
            let translations = (dict[UserDefaultsKey.translations.key] as? [String]) ?? dict[Verb.translationsKey] as? [String],
        let tenseArray = dict[UserDefaultsKey.tenses.key] as? [String: JSONArray] ?? dict[Verb.tensesKey] as? [String: JSONArray]
            else { return nil }
        
        var tenses = Tenses()
        TenseGroup.allCases.forEach { tenseGroup in
            if let tense = tenseArray[tenseGroup.rawValue] {
                tenses[tenseGroup] = tense.flatMap {
                    guard let dict = $0 as? JSONDictionary else { return nil }
                    return Tense.from(dict: dict, tenseGroup: tenseGroup)
                }
            }
        }
        
        let nominalForms = dict[UserDefaultsKey.nominalForms.key] as? [String] ?? (dict[Verb.nominalFormKey] as? [String] ?? [String]())
        
        let languageIdentifier = dict[UserDefaultsKey.language.key] as? String ?? ""
        
        //Language property was introduced with v1.2 together with multi-lingual conjugation. If this doesn't exist, it the verb should be in German as that was the only language supported before that
        let language = Language(localeIdentifier: languageIdentifier) ?? .german
        
        return self.init(name: name, language: language, translations: translations, tenses: tenses, nominalForms: nominalForms)
    }
}

struct Tense {
    
    //TODO: DEPRECATED - REMOVE WHEN POSSIBLE
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
        case pluperfect
        
        case noTense = ""
        
    }
    
    enum UserDefaultsKey: String, DictionaryKey {
        case name
        case verbixID
        case tenseGroup
        case forms
    }
    
    static let nameKey = "name"
    static let formsKey = "forms"
    
    let verbixID: String
    let tenseGroup: TenseGroup
    let forms: [Form]
    
    var order: Int {
        return tenseGroup.sortedTenseIDs.index(of: verbixID) ?? 0
    }
    
    func localizedTitle(in language: Language) -> String {
        return LocalizedString("mobile.ios.conjugate.tense.\(verbixID)", in: language)
    }
}

extension Tense: Equatable {
    static func ==(lhs: Tense, rhs: Tense) -> Bool {
        return lhs.verbixID == rhs.verbixID
    }
}

extension Tense: Comparable {
    static func <(lhs: Tense, rhs: Tense) -> Bool {
        return  lhs.order < rhs.order
    }
}

extension Tense: DictConvertible {
    func asDict() -> JSONDictionary {
        var dict = JSONDictionary()
        
        dict[Tense.UserDefaultsKey.verbixID.key] = verbixID
        dict[Tense.UserDefaultsKey.forms.key] = forms.map { $0.asDict() }
        
        return dict
    }
    
    static func from(dict: JSONDictionary) -> Tense? {
        //Tense group parameter is a workaround for the saved verbs with the old tense structure. This will be removed after being sure that there are no saved verbs with the old tense structure
        return from(dict: dict, tenseGroup: .indicative)
    }
    
    static func from(dict: JSONDictionary, tenseGroup: TenseGroup) -> Tense? {
        guard let formsArray = dict[Tense.formsKey] as? [JSONDictionary]
            else { return nil }
        
        let verbixID: String
        
        if let nameString = dict[Tense.nameKey] as? String,
            let name = Tense.Name(rawValue: nameString){
            verbixID = getVerbixID(from: name, tenseGroup: tenseGroup)
        } else {
            verbixID = dict[Tense.UserDefaultsKey.verbixID.key] as? String ?? ""
        }
        
        let forms = formsArray.flatMap { Form.from(dict: $0) }
        
        //Workaround for old saved verbs that doesn't have the tense group saved
        let tenseGroup: TenseGroup = dict[Tense.UserDefaultsKey.tenseGroup.key] as? TenseGroup ?? tenseGroup
        
        return self.init(verbixID: verbixID, tenseGroup: tenseGroup, forms: forms)
    }
    
    //Temp function to map tense names to verbixIDs. This will be removed after Tense.Name enum is removed
    static func getVerbixID(from tenseName: Tense.Name, tenseGroup: TenseGroup) -> String {
        switch (tenseGroup, tenseName) {
        case (_, .noTense):
            return "8" //Imperative
        case (.indicative, .present):
            return "0"
        case (.subjunctive,.present):
            return "1"
        case (.indicative, .past):
            return "2"
        case (.subjunctive, .past):
            return "3"
        default:
            return tenseName.verbixId!
        }
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


