//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result

protocol DataClient {
    func search(for verb: String, in language: Language, completion: @escaping ResultHandler)
    func translate(for verb: String, from: Language, to: Language, completion: @escaping ResultHandler)
    func conjugate(for verb: String, in language: Language, completion: @escaping ResultHandler)
    func cancelAllOperations()
}


