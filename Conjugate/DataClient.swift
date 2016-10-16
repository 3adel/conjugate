//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result

protocol DataClient {
    func search(for verb: String, in language: Locale, completion: @escaping ResultHandler)
    func translate(for verb: String, from: Locale, to: Locale, completion: @escaping ResultHandler)
    func conjugate(for verb: String, in language: Locale, completion: @escaping ResultHandler)
}


