//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

class Storage {
    
    static let verbsKey = "verbsKey"
    
    let userDefaults: UserDefaults
    
    var savedVerbs = [Verb]()
    var savedVerbDictArray: [JSONDictionary] = []
    
    var savedVerbsDidChange = false
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    @discardableResult func getSavedVerbs() -> [Verb] {
        guard let savedArray = userDefaults.array(forKey: Storage.verbsKey) as? [JSONDictionary]
            else { return [Verb]() }
        
        savedVerbDictArray = savedArray
        
        savedVerbs =  savedArray.flatMap {
            return Verb.from(dict: $0)
        }
        
        return savedVerbs
    }
    
    func saveVerbs() {
        userDefaults.set(savedVerbDictArray, forKey: Storage.verbsKey)
    }
    
    func verbExists(_ verb: Verb) -> Bool {
        return !savedVerbs.filter { $0 == verb }.isEmpty
    }
    
    func save(verb: Verb) {
        if savedVerbs.index(of: verb) == nil {
            
            savedVerbs.insert(verb, at: 0)
            savedVerbDictArray.insert(verb.asDict(), at: 0)
            saveVerbs()
        }
    }
    
    func remove(verb: Verb) {
        if let indexOfVerb = savedVerbs.index(of: verb) {
            savedVerbs.remove(at: indexOfVerb)
            savedVerbDictArray.remove(at: indexOfVerb)
            saveVerbs()
        }
    }
}
