//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

struct Verb {
    enum TenseGroup: String {
        case indicative
        case conditional
        case imperative
    }

    let name: String
    let tenses: [TenseGroup: [Tense]]
}

struct Tense {
    enum Name: String {
        case present
        case past
        case future
    }
    
    let name: Name
    let forms: [Form]
}

struct Form {
    let pronoun: String
    let irregular: Bool
    let conjugatedVerb: String
}



