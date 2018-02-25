//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String: Any]
public typealias JSONArray = [Any]
public typealias JSONNumber = Double
public typealias JSONString = String

/**
 
 Implement this protocol to allow a object to be initiated with a JSONDictionary instance
 
 */
public protocol JSONDictInitable {
    init?(with dict: JSONDictionary)
}

open class ModelFactory {
    open static func arrayOf<T:JSONDictInitable>(_ inArray:[JSONDictionary]?) -> [T] {
        
        guard let inArray = inArray else { return [] }
        
        return inArray.flatMap { T(with: $0) }
    }
    
    open static func dictionaryOf<T:JSONDictInitable>(_ inDict:[String : JSONDictionary]?) -> [String : T] {
        
        guard let inDict = inDict else { return [:] }
        
        return inDict.reduce([String: T]()) { (dict, element) in
            var dictionary = dict
            dictionary[element.0] = T(with: element.1)
            return dictionary
        }
    }
}

extension Verb {
    init?(with dict: JSONDictionary, language: Language) {
        guard let name = dict["verb"] as? String else { return nil }
        
        let tensesDict = dict["tenses"] as? [String: JSONDictionary]
        
        var tenses: [TenseGroup: [Tense]] = language.tenseGroups.reduce([TenseGroup: [Tense]]()) { dict, tenseGroup in
            
            var newDict = dict
            newDict[tenseGroup] = []
            return newDict
        }
        
        var nominalForms = [String]()
        if let tensesDict = tensesDict {
            nominalForms = TenseGroup.nominal.ids.reduce([]) { forms, id in
                guard let tenseDict = tensesDict[id],
                    let formsArray = tenseDict["forms"] as? JSONArray,
                    let formDict = formsArray.first as? JSONDictionary,
                    let form = formDict["form"] as? String
                    else { return forms }
                
                var finalForms = forms
                finalForms.append(form.trimmingWhitespaces())
                
                return finalForms
            }
            
            for (key, value) in tensesDict {
                
                guard let tenseGroup = TenseGroup(verbixId: key, language: language),
                    let tense = Tense(with: value, verbixID: key, tenseGroup: tenseGroup, language: language) else { continue }
                
                tenses[tenseGroup]?.append(tense)
            }
        }
        
        // isRegular = tenses.filter (tense groups that have at least one tense that has at least one irregular form).isEmpty
        let isRegular = tenses.filter {!$0.value.filter { !$0.forms.filter { $0.type == .irregular }.isEmpty}.isEmpty }.isEmpty
        let regularity: Regularity = isRegular ? .regular : .irregular
        let auxiliaryVerb = (dict["auxiliaries"] as? [String])?.first ?? ""
        
        self.init(name: name, language: language, auxiliaryVerb: auxiliaryVerb, regularity: regularity, tenses: tenses, nominalForms: nominalForms)
    }
}

extension Tense {
    init?(with dict: JSONDictionary, verbixID: String, tenseGroup: TenseGroup, language: Language) {
        guard let formDicts = dict["forms"] as? [JSONDictionary] else { return nil }
        
        let forms: [Form] = ModelFactory.arrayOf(formDicts)
        
        self.init(verbixID: verbixID, tenseGroup: tenseGroup, forms: forms)
    }
}

extension Tense.Name {
    var verbixId: String? {
        switch self {
        case .present:
            return "0"
        case .past:
            return "2"
        case .presentPerfect:
            return "10"
        case .pastPerfect:
            return "12"
        case .future:
            return "5"
        case .future2:
            return "15"
        case .conditionalPast:
            return "7"
        case .conditionalPastPerfect:
            return "17"
        case .subjunctivePastPerfect:
            return "13"
        case .subjunctivePresentPerfect:
            return "11"
        case .preterite:
            return "4"
        case .preterite2:
            return "14"
        case .subjunctiveFuture:
            return "6"
        case .subjunctiveFuture2:
            return "16"
        case .pluperfect:
            return "9"
        case .noTense:
            return "-1"
        }
    }
}

extension Form: JSONDictInitable {
    init?(with dict: JSONDictionary) {
        guard var pronoun = dict["pronoun"] as? String,
            let use = dict["use"] as? Int,
            let form = dict["form"] as? String else { return nil }
        
        let type = FormType(rawValue: use) ?? FormType.regular
        
        //Workaround for bad structure of the pronouns in API response
        if pronoun.contains("er") {
            pronoun = "er/sie/es"
        } else {
            //Replace the seperator ";" that is used by the API for multiple pronouns, with "/" which looks better
            pronoun = pronoun.replacingOccurrences(of: ";", with: "/")
        }
        
        self.init(pronoun: pronoun, type: type, conjugatedVerb: form)
    }
}

extension Translation: JSONDictInitable {
    init?(with dict: JSONDictionary) {
        guard let verb = dict["translation"] as? String,
            let meaning = dict["meaning"] as? String
            else { return nil }
        
        let unwantedCharacters = CharacterSet(charactersIn: "\\[]()")
        let strippedVerb = verb.removingCharacters(in: unwantedCharacters)
        let strippedMeaning = meaning.removingCharacters(in: unwantedCharacters)
        
        self.init(verb: strippedVerb, meaning: strippedMeaning)
    }
}

extension String {
    var firstComponent: String? {
        let stringComponents = components(separatedBy: " ")
        return stringComponents.count >= 1 ? stringComponents[0] : nil
    }
    var secondComponent: String? {
        let stringComponents = components(separatedBy: " ")
        return stringComponents.count >= 2 ? stringComponents[1] : nil
    }
    
    func adding(components: [String], withSeperator seperator: String = "") -> String {
        return components.reduce("") { $0 + seperator + $1 }
    }
}

extension String {
    func removingCharacters(in characterSet: CharacterSet) -> String {
        return components(separatedBy: characterSet).joined()
    }
    
    func trimmingWhitespaces() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }
}
