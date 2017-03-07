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
    
    func search(for verb: String, in language: Language, completion: @escaping ResultHandler) {
        cancelAllOperations()
        
        let endpoint = Endpoint.finder
        
        let languageCode = language.isoCode
        
        guard let request = webClient.createRequest(endpoint: endpoint, ids: ["fromLanguageKey": languageCode, "verbKey": verb.lowercased()])
            else {
                let errorResult: AnyResult = .failure(ConjugateError.genericError)
                completion(errorResult)
                return
        }
        send(request: request, endpoint: endpoint, completion: completion)
    }
    
    func conjugate(for verb: String, in language: Language, completion: @escaping (AnyResult) -> Void) {
        cancelAllOperations()
        
        let endpoint = Endpoint.conjugator
        
        let languageCode = language.isoCode
        
        guard let request = webClient.createRequest(endpoint: endpoint, ids: ["fromLanguageKey": languageCode, "verbKey": verb.lowercased()])
            else {
                completion(genericErrorResult)
                return
        }
        
        send(request: request, endpoint: endpoint, completion: completion)
    }
    
    func translate(for verb: String, from: Language, to: Language, completion: @escaping (AnyResult) -> Void) {
        cancelAllOperations()
        
        let endpoint = Endpoint.translator
        
        guard let request = webClient.createRequest(endpoint: endpoint, ids: ["fromLanguageKey": from.languageCode, "toLanguageKey": to.languageCode, "verbKey": verb.lowercased()])
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
