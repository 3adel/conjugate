//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result

typealias AnyAPIResult = Result<Any, APIError>
typealias AnyResult = Result<Any, ConjugateError>

typealias ResultHandler = (AnyResult) -> Void

class APIClient: DataClient {
    let webClient = WebClient()
    
    let genericErrorResult: AnyResult = .failure(ConjugateError.genericError)
    
    func search(for verb: String, in language: Locale, completion: @escaping ResultHandler) {
        cancelAllOperations()
        
        let endpoint = Endpoint.finder
        
        guard let languageCode = language.isoLanguageCode,
            let request = webClient.createRequest(endpoint: endpoint, ids: ["fromLanguageKey": languageCode, "verbKey": verb])
            else {
                let errorResult: AnyResult = .failure(ConjugateError.genericError)
                completion(errorResult)
                return
        }
        send(request: request, endpoint: endpoint, completion: completion)
    }
    
    func conjugate(for verb: String, in language: Locale, completion: @escaping (AnyResult) -> Void) {
        cancelAllOperations()
        
        let endpoint = Endpoint.conjugator
        
        guard let languageCode = language.isoLanguageCode,
            let request = webClient.createRequest(endpoint: endpoint, ids: ["fromLanguageKey": languageCode, "verbKey": verb])
            else {
                completion(genericErrorResult)
                return
        }
        
        send(request: request, endpoint: endpoint, completion: completion)
    }
    
    func translate(for verb: String, from: Locale, to: Locale, completion: @escaping (AnyResult) -> Void) {
        cancelAllOperations()
        
        let endpoint = Endpoint.translator
        
        guard let fromLanguageCode = from.languageCode,
            let toLanguageCode = to.languageCode,
            let request = webClient.createRequest(endpoint: endpoint, ids: ["fromLanguageKey": fromLanguageCode, "toLanguageKey": toLanguageCode, "verbKey": verb])
            else {
                completion(genericErrorResult)
                return
        }
        
        send(request: request, endpoint: endpoint, completion: completion)
    }
    
    func cancelAllOperations() {
        webClient.cancellAllRequests()
    }
    
    func send(request: URLRequest, endpoint: Endpoint, completion: @escaping ResultHandler) {
        webClient.send(request, cache: false) { result in
            switch (result) {
            case .failure(let apiError):
                let appError = Endpoint.finder.appError(from: apiError)
                let result: AnyResult = .failure(appError)
                completion(result)
            case .success(let apiResult):
                let result = AnyResult(apiResult)
                completion(result)
            }
        }
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
