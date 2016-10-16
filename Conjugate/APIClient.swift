//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result

typealias AnyResult = Result<Any, ConjugateError>

class APIClient: DataClient {
    let webClient = WebClient()
    
    let genericErrorResult: AnyResult = .failure(ConjugateError.genericError)
    
    func search(for verb: String, in language: Locale, completion: @escaping ResultHandler) {
        guard let languageCode = language.isoLanguageCode,
            let request = webClient.createRequest(endpoint: .finder, ids: ["fromLanguageKey": languageCode, "verbKey": verb])
            else {
                let errorResult: AnyResult = .failure(ConjugateError.genericError)
                completion(errorResult)
                return
        }
        
        webClient.send(request, cache: false, completion: completion)
    }
    
    func conjugate(for verb: String, in language: Locale, completion: @escaping (AnyResult) -> Void) {
        guard let languageCode = language.isoLanguageCode,
            let request = webClient.createRequest(endpoint: .conjugator, ids: ["fromLanguageKey": languageCode, "verbKey": verb])
            else {
                completion(genericErrorResult)
                return
        }
        
        webClient.send(request, cache: false, completion: completion)
    }
    
    func translate(for verb: String, from: Locale, to: Locale, completion: @escaping (AnyResult) -> Void) {
        guard let fromLanguageCode = from.isoLanguageCode,
            let toLanguageCode = to.isoLanguageCode,
            let request = webClient.createRequest(endpoint: .translator, ids: ["fromLanguageKey": fromLanguageCode, "toLanguageKey": toLanguageCode, "verbKey": verb])
            else {
                completion(genericErrorResult)
                return
        }
        
        webClient.send(request, cache: false, completion: completion)
    }
}

extension Locale {
    private enum Language: String {
        case de
        case en
        
        var isoLanguageCode: String {
            switch self {
            case .de:
                return "deu"
            case .en:
                return "eng"
            }
        }
    }
    
    public var isoLanguageCode: String?  {
        guard let languageCode = languageCode,
            let language = Language(rawValue: languageCode) else { return nil }
        
        return language.isoLanguageCode
    }
}
