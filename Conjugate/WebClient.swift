//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Alamofire
import Crashlytics


public enum ServerErrorUserInfoKey: String {
    case Error
    case Request
    case Response
    
    public var key: String {
        return self.rawValue
    }
}

public enum ContentType: String {
    case applicationJson = "application/json"
    case applicationFormUrlEncoded = "application/x-www-form-urlencoded"
    case multipartFormData = "multipart/form-data"
    case textHtml = "text/html"
    case imagePng = "image/png"
    
    public static var header: String {
        return "Content-Type"
    }
}

typealias APIResultHandler = (AnyAPIResult) -> Void

class WebClient {
    
    static let RequestTimeOut: TimeInterval = 60

    let manager: Alamofire.SessionManager
    
    var reachabilityManager: NetworkReachabilityManager?
    var reachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus?
    
    var cancelledRequests: [URLRequest] = []
    
    init(manager: Alamofire.SessionManager? = nil) {
        self.manager = manager ?? Alamofire.SessionManager.default
    }
    
    func createRequest(endpoint: Endpoint, ids: [Token:String]? = nil, queryItems: [URLQueryItem]? = nil, json: Data? = nil, method: HTTPMethod = .GET, cache: Bool = false) -> URLRequest? {
        
        guard let fullURLString = Endpoint.urlString(from: endpoint, ids: ids, queryItems: queryItems),
            let url = URL(string: fullURLString)
            else { return nil }
        
        let cachePolicy: URLRequest.CachePolicy = cache ? .returnCacheDataElseLoad : .reloadIgnoringLocalAndRemoteCacheData
        
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: WebClient.RequestTimeOut)
        
        if let json = json {
            do {
                request.httpBody = json
                request.setValue(ContentType.applicationJson.rawValue, forHTTPHeaderField: ContentType.header)
            }
            catch {
                //FIX-IT: If JSON payload cannot be serialised, an error should be thrown
            }
        }
        request.httpMethod = method.rawValue
        return request
    }
    
    func send(_ request: URLRequest, cache: Bool = false, completion: APIResultHandler? = nil) {
        setupReachabilityManager(for: request.url?.host ?? "")
        
        removeRequestFromCancelled(request)
        
        manager.request(request)
            .validate()
            .responseJSON { alamofireResponse in
                guard !self.requestIsCancelled(alamofireResponse.request)
                    else {
                        self.removeRequestFromCancelled(alamofireResponse.request)
                        return
                }
                
                var result: AnyAPIResult!
                
                switch alamofireResponse.result {
                case .failure(_):
                    if let reachabilityStatus = self.reachabilityStatus,
                        reachabilityStatus == .notReachable || reachabilityStatus == .unknown {
                        result = .failure(APIError.networkUnavailable)
                    } else {
                        guard let statusCode = alamofireResponse.response?.statusCode
                            else {
                                result = .failure(APIError.genericNetworkError)
                                break
                        }
                        let error = APIError(statusCode: statusCode) ?? APIError.genericNetworkError
                        result = .failure(error)
                    }
                case .success(let value):
                    result = .success(value)
                }
            completion?(result)
        }
    }
    
    func requestIsCancelled(_ request: URLRequest?) -> Bool {
        var isCancelled = false
        
        for cancelledRequest in cancelledRequests {
            guard let request = request
                else { continue }
            
            isCancelled = request.url == cancelledRequest.url
            
            if isCancelled {
                break
            }
        }
        
        return isCancelled
    }
    
    func removeRequestFromCancelled(_ request: URLRequest?) {
        guard let request = request else { return }
        cancelledRequests.remove(request)
    }
    
    func cancellAllRequests() {
        manager.session.getAllTasks { tasks in
            tasks.forEach { [weak self] in
                guard let strongSelf = self else { return }
                
                if let request = $0.currentRequest,
                    !strongSelf.cancelledRequests.contains(request) {
                    
                    strongSelf.cancelledRequests.append(request)
                }
                $0.cancel()
            }
        }
    }
    
    func setupReachabilityManager(for host: String) {
        reachabilityManager?.stopListening()
        
        reachabilityManager = Alamofire.NetworkReachabilityManager(host: host)
        reachabilityManager?.listener = listenTo
        reachabilityManager?.startListening()
    }
    
    func listenTo(reachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus) {
        self.reachabilityStatus = reachabilityStatus
    }
}

public typealias Token = String
public typealias Parameter = String


public enum Endpoint: String {
    
    public static var baseURI: String = ""
    public static var apiKey: String = ""
    
    // MARKK - Locales
    case conjugator
    case finder
    case translator
    
    public var path: String {
        switch self {
        case .translator:
            return "translatorv2"
        default:
            return self.rawValue
        }
    }
    
    public var endTokens: String {
        switch self {
        case .conjugator:
            return "fromLanguageKey/verbKey"
        case .finder:
            return "fromLanguageKey/verbKey"
        case .translator:
            return "fromLanguageKey/toLanguageKey/verbKey"
        }
    }
    
    
    public func appError(from apiError: APIError) -> ConjugateError {
        if apiError == .serverError {
            
            
            Answers.logCustomEvent(withName: "Error-server",customAttributes: ["Error": apiError.localizedDescription])
            
            return ConjugateError.serverError
            

            
        } else if apiError == .networkUnavailable {
            
            Answers.logCustomEvent(withName: "Error-network-unavailable",customAttributes: ["Error": apiError.localizedDescription])
            
            return ConjugateError.networkUnavailable
            
            
            
        }
        
        switch (self) {
        case .conjugator:
            switch (apiError) {
            case .notFound:
                return ConjugateError.conjugationNotFound
            default:
                break
            }
            
        case .finder:
            switch (apiError) {
            case .notFound:
                return ConjugateError.verbNotFound
            default:
                break
            }
        case .translator:
            switch (apiError) {
            case .notFound:
                return ConjugateError.translationNotFound
            default:
                break
            }
        }
        
        
        Answers.logCustomEvent(withName: "Error-unknown",customAttributes: ["Error": ConjugateError.genericError.localizedDescription])
        
        return ConjugateError.genericError
    }
    
    public static func urlString(from endpoint: Endpoint, ids:[Token:String]?, queryItems: [URLQueryItem]? = nil) -> String? {
        // convert baseURI string to NSURL to avoid cropping of protocol information:
        var baseURL = URL(string: baseURI)
        // appended path components will be URL encoded automatically:
        baseURL = baseURL!.appendingPathComponent(endpoint.path).appendingPathComponent("json/\(apiKey)").appendingPathComponent(endpoint.endTokens)
        // re-decode URL components so token placeholders can be replaced later:
        var populatedEndPoint: String = baseURL!.absoluteString.removingPercentEncoding!
        
        if let replacements = ids {
            for (token, value) in replacements {
                populatedEndPoint = populatedEndPoint.replacingOccurrences(of: token, with: value)
            }
        }
        
        if var urlComponents = URLComponents(string: populatedEndPoint) {
            urlComponents.queryItems = queryItems
            return urlComponents.string ?? populatedEndPoint
        }
        return populatedEndPoint.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)
    }
}

private extension String {
    func stringByAppendingPathComponent(_ comp: String) -> String {
        return self + "/" + comp
    }
}

public enum HTTPMethod: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

protocol URLRequestType {
    var url: URL? { get }
}

extension URLRequest: URLRequestType {}

extension Array where Element: URLRequestType {
    
    mutating func remove(_ request: URLRequestType) {
        var indexesToBeRemoved: [Int] = []
        
        self.enumerated().forEach {
            if $0.element.url == request.url {
                indexesToBeRemoved.append($0.offset)
            }
        }
        
        indexesToBeRemoved.forEach { remove(at: $0) }
    }
}
