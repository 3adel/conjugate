//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result


class DataStore {
    private static let defaultClient = APIClient()
    
    private let dataClient: DataClient
    
    init(dataClient: DataClient? = nil) {
        self.dataClient = dataClient ?? DataStore.defaultClient
    }
    
    func getInfinitive(of verbString: String, in language: Locale, completion: @escaping (Result<Verb, ConjugateError>) -> Void) {
        dataClient.search(for: verbString, in: language) { result in
            switch result {
            case .failure (let error):
                completion(.failure(error))
            case .success(let value):
                guard let array = value as? JSONArray,
                    let dict = array.first as? JSONDictionary,
                    let verb = Verb(with: dict)
                    else {
                        completion(.failure(ConjugateError.verbNotFound))
                        return
                }
                completion(.success(verb))
            }
            
        }
    }
    
    func conjugate(_ verb: String, in language: Locale, completion: @escaping (Result<Verb, ConjugateError>) -> Void) {
        dataClient.conjugate(for: verb, in: language) { result in
            switch result {
            case .failure (let error):  
                completion(.failure(error))
            case .success(let value):
                guard let dict = value as? JSONDictionary,
                    let verb = Verb(with: dict)
                    else {
                        completion(.failure(ConjugateError.conjugationNotFound))
                        return
                }
                completion(.success(verb))
            }
        }
    }
    
    func getTranslation(of verb: Verb, in fromLanguage: Locale, for toLanguage: Locale, completion: @escaping (Result<Verb, ConjugateError>) -> Void) {
        dataClient.translate(for: verb.name, from: fromLanguage, to: toLanguage) { result in
            switch result {
            case .failure (let error):
                completion(.failure(error))
            case .success(let value):
                guard let array = value as? [JSONDictionary]
                    else {
                        completion(.failure(ConjugateError.translationNotFound))
                        return
                }
                
                var translations = [String]()
                array.forEach { dict in
                    guard let translation = dict["translation"] as? String,
                        !translations.contains(translation)
                        else { return }
                    translations.append(translation)
                }
                
                let newVerb = Verb(name: verb.name, translations: translations, tenses: verb.tenses)
                completion(.success(newVerb))
            }
        }
    }
    
}

