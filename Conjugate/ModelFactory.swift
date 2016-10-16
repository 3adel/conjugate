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
            .imperative: []
        ]
        
        if let tensesDict = tensesDict {
            for (_, value) in tensesDict {
                guard let tense = Tense(with: value),
                    let name = value["name"] as? String,
                    let firstComponent = name.firstComponent,
                    let tenseGroup = TenseGroup(rawValue: firstComponent) else { continue }
                
                tenses[tenseGroup]?.append(tense)
            }
        }
        
        self.init(name: name, tenses: tenses)
    }
}

extension Tense: JSONDictInitable {
    init?(with dict: JSONDictionary) {
        guard let nameString = dict["name"] as? String,
            let name = Tense.Name(rawValue: nameString),
            let formDicts = dict["forms"] as? [JSONDictionary] else { return nil }
        
        let forms: [Form] = ModelFactory.arrayOf(formDicts)
        self.init(name: name, forms: forms)
    }
}


extension Form: JSONDictInitable {
    init?(with dict: JSONDictionary) {
        guard let pronoun = dict["pronoun"] as? String,
            let use = dict["use"] as? Int,
            let form = dict["form"] as? String else { return nil }
        
        let irregular = use == 0
        
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
        return stringComponents.count >= 2 ? stringComponents[2] : nil
    }
}
