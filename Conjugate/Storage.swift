//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

class Storage {
    
    static let verbsKey = "verbsKey"
    
    let userDefaults: UserDefaults
    var savedVerbs = [Verb]()
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    @discardableResult func getSavedVerbs() -> [Verb] {
        guard let savedArray = userDefaults.array(forKey: Storage.verbsKey)
            else { return [Verb]() }
        
        savedVerbs =  savedArray.flatMap {
            guard let dict = $0 as? JSONDictionary else { return nil }
            return Verb.from(dict: dict)
        }
        
        return savedVerbs
    }
    
    func saveVerbs() {
        let savedArray = savedVerbs.map { $0.asDict() }
        userDefaults.set(savedArray, forKey: Storage.verbsKey)
    }
    
    func verbExists(_ verb: Verb) -> Bool {
        return !savedVerbs.filter { $0 == verb }.isEmpty
    }
    
    func save(verb: Verb) {
        if savedVerbs.index(of: verb) == nil {
            savedVerbs.insert(verb, at: 0)
            saveVerbs()
        }
    }
    
    func remove(verb: Verb) {
        if let indexOfVerb = savedVerbs.index(of: verb) {
            savedVerbs.remove(at: indexOfVerb)
            saveVerbs()
        }
    }
}
