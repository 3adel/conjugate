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
            .conditional: [],
            .imperative: [],
            .subjunctive: [],
        ]
        
        if let tensesDict = tensesDict {
            for (key, value) in tensesDict {
                
                guard let tense = Tense(with: value, verbixId: key),
                    let name = value["name"] as? String,
                    let firstComponent = name.firstComponent?.lowercased(),
                    let tenseGroup = TenseGroup(rawValue: firstComponent) else { continue }
                
                tenses[tenseGroup]?.append(tense)
            }
        }
        
        self.init(name: name, tenses: tenses)
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
        
        let irregular = use != 0
        
        //Workaround for bad structure of the pronouns in API response
        if pronoun.contains("er") {
            pronoun = "er/sie/es"
        } else {
            //Replace the seperator ";" that is used by the API for multiple pronouns, with "/" which looks better
            pronoun = pronoun.replacingOccurrences(of: ";", with: "/")
        }
        
        self.init(pronoun: pronoun, irregular: irregular, conjugatedVerb: form)
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
