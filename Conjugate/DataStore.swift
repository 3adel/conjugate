//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result

enum ConjugateError: Error {
    case genericError
}

class DataStore {
    private static let defaultClient = APIClient()
    
    private let dataClient: DataClient
    
    init(dataClient: DataClient? = nil) {
        self.dataClient = dataClient ?? DataStore.defaultClient
    }
    
    func search(for verbString: String, in language: Locale, completion: @escaping (Result<Verb, ConjugateError>) -> Void) {
        dataClient.search(for: verbString, in: language) { result in
            switch result {
            case .failure:
                completion(.failure(ConjugateError.genericError))
            case .success(let value):
                guard let array = value as? JSONArray,
                    let dict = array.first as? JSONDictionary,
                    let verb = Verb(with: dict) else {
                    completion(.failure(ConjugateError.genericError))
                    return
                }
                completion(.success(verb))
            }
            
        }
    }
    
}

