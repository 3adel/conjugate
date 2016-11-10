//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation


public enum ConjugateError: ConjugateErrorType {
    case genericError
    case verbNotFound
    case translationNotFound
    case conjugationNotFound
    case serverError
    case networkUnavailable
    
    public var _domain: String {
        return domainBase+".error"
    }
}

public protocol ConjugateErrorType: Error {
    var code: Int {get}
    var domain: String {get}
    var domainBase: String {get}
    var localizedDescriptionKey: String {get}

}

extension ConjugateErrorType {
    
    public var code: Int {
        return _code
    }
    public var domain: String {
        return _domain
    }
    public var domainBase: String {
        return "mobile.ios.conjugate"
    }
    public var localizedDescriptionKey: String {
        let endIndex = "\(self)".range(of: "(")?.lowerBound ?? "\(self)".endIndex
        return "\(domain)."+"\(self)".substring(to: endIndex)
    }
    
    public var localizedMessage: String {
        return LocalizedString(localizedDescriptionKey)
    }
}

extension Error where Self: ConjugateErrorType {
    public var localizedDescription: String {
        let message = localizedMessage
        return message
    }
}

public enum APIError: Error {
    case notFound
    case badRequest
    case serverError
    case genericNetworkError
    case networkUnavailable
    
    init?(statusCode: Int) {
        switch(statusCode) {
        case 400:
            self = APIError.badRequest
        case 404:
            self = APIError.notFound
        case 500, 501, 502, 503:
            self = APIError.serverError
        default:
            if APIError.allErrorStatusCodes.contains(statusCode) {
                self = APIError.genericNetworkError
            } else {
                return nil
            }
        }
    }
    
    static var clientErrorStatusCodes: Range<Int> {
        return 400..<500
    }
    
    static var serverErrorStatusCodes: Range<Int> {
        return 500..<600
    }
    
    static var allErrorStatusCodes: ClosedRange<Int> {
        return clientErrorStatusCodes.lowerBound...serverErrorStatusCodes.upperBound
    }
}
