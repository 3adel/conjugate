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

extension Verb: JSONDictInitable {
    init?(with dict: JSONDictionary) {
        guard let name = dict["verb"] as? String else { return nil }
        
        let tensesDict = dict["tenses"] as? [String: JSONDictionary]
        
        var tenses: [TenseGroup: [Tense]] = [
            .indicative: [],
            .imperative: [],
            .subjunctive: [],
        ]
        
        var nominalForms = [String]()
        if let tensesDict = tensesDict {
            nominalForms = TenseGroup.nominal.ids.reduce([]) {
                guard let tenseDict = tensesDict[$0.1],
                    let formsArray = tenseDict["forms"] as? JSONArray,
                    let formDict = formsArray.first as? JSONDictionary,
                    let form = formDict["form"] as? String
                    else { return $0.0 }
                
                var finalForms = $0.0
                finalForms.append(form)
                
                return finalForms
            }
            
            for (key, value) in tensesDict {
                
                guard let tense = Tense(with: value, verbixId: key),
                    let name = value["name"] as? String,
                    let firstComponent = name.firstComponent?.lowercased(),
                    var tenseGroup = TenseGroup(rawValue: firstComponent) else { continue }
                
                if tenseGroup == .conditional {
                    tenseGroup = .subjunctive
                }
                
                tenses[tenseGroup]?.append(tense)
            }
        }
        
        self.init(name: name, tenses: tenses, nominalForms: nominalForms)
    }
}

extension Tense {
    init?(with dict: JSONDictionary, verbixId: String = "") {
        guard let nameString = dict["name"] as? String,
            let name = Tense.Name(verbixId: verbixId) ?? Tense.Name(rawValue: nameString.secondComponent?.lowercased() ?? ""),
            let formDicts = dict["forms"] as? [JSONDictionary] else { return nil }
        
        let forms: [Form] = ModelFactory.arrayOf(formDicts)
        self.init(name: name, forms: forms)
    }
}

extension Tense.Name {
    var verbixId: String? {
        switch self {
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
        default:
            return nil
        }
    }
    
    init?(verbixId: String) {
        var tense: Tense.Name? = nil
        
        Tense.Name.allTenses.forEach { name in
            if verbixId == name.verbixId {
                tense = name
            }
        }
        
        guard let name = tense else { return nil }
        self = name
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
        let stringComponents = components(separatedBy: "/")
        return stringComponents.count >= 1 ? stringComponents[1] : nil
    }
    var secondComponent: String? {
        let stringComponents = components(separatedBy: "/")
        return stringComponents.count >= 3 ? stringComponents[2] : nil
    }
    
    func adding(components: [String], withSeperator seperator: String = "") -> String {
        return components.reduce("") { $0 + seperator + $1 }
    }
}

extension String {
    func removingCharacters(in characterSet: CharacterSet) -> String {
        return components(separatedBy: characterSet).joined()
    }
}
