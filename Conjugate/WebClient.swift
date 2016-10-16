//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Alamofire


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

typealias ResultHandler = (AnyResult) -> Void

class WebClient {
    
    static let RequestTimeOut: TimeInterval = 60

    let manager: Alamofire.SessionManager
    
    init(manager: Alamofire.SessionManager? = nil) {
        self.manager = manager ?? Alamofire.SessionManager.default
    }
    
    func createRequest(endpoint: Endpoint, ids: [Token:String]? = nil, queryItems: [URLQueryItem]? = nil, json: Data? = nil, method: HTTPMethod = .GET, cache: Bool = false) -> URLRequest {
        
        let fullURLString = Endpoint.urlString(from: endpoint, ids: ids, queryItems: queryItems)
        let url = URL(string: fullURLString)!
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
    
    func send(_ request: URLRequest, cache: Bool = false, completion: ResultHandler? = nil) {
        manager.request(request)
            .validate()
            .responseJSON { response in
                var result: AnyResult!

                switch response.result {
                case .failure(_):
                    result = .failure(ConjugateError.genericError)
                case .success(let value):
                    result = .success(value)
                }
            completion?(result)
        }
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
        return self.rawValue
    }
    
    public var endTokens: String {
        switch self {
        case .conjugator:
            return "fromLanguage/verbKey"
        case .finder:
            return "fromLanguage/verbKey"
        case .translator:
            return "fromLanguage/toLanguage/verbKey"
        }
    }
    
    public static func urlString(from endpoint: Endpoint, ids:[Token:String]?, queryItems: [URLQueryItem]? = nil) -> String {
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
        return populatedEndPoint
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
