import Foundation

public typealias HTTPHeaders = [String: String]
public typealias HTTPParemeters = [String: Any]

public extension VZNetwork {
    class Request {
        internal var _start: (() -> Void)?
        internal var _end: (() -> Void)?
        internal var _result: ((_ result: VZNetwork.Result) -> Void)?
        public var request: URLRequest
        
        public init(with request: URLRequest) {
            self.request = request
        }
        
        public func start(_ action: @escaping () -> Void) -> VZNetwork.Request {
            _start = action
            return self
        }
        
        public func result(_ action: @escaping (_ result: VZNetwork.Result) -> Void) -> VZNetwork.Request {
            _result = action
            return self
        }
        
        public func end(_ action: @escaping () -> Void) -> VZNetwork.Request {
            _end = action
            return self
        }
    }
}

extension VZNetwork.Request {
    public convenience init?(url: String, method: String = "GET") {
        guard let url = URL(string: url) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        self.init(with: request)
    }
    
    public convenience init?(url: String, method: String = "GET", parameters: HTTPParemeters, headers: HTTPHeaders, media: [VZNetwork.Media]?) {
        guard let request = VZNetwork.Request.request(url: url, method: method, parameters: parameters, headers: headers, media: media) else { return nil }
        self.init(with: request)
    }
    
    public func add(etag: String) {
        self.request.addValue(etag, forHTTPHeaderField: "If-None-Match")
    }
    
    private static func request(url: String, method: String = "GET", parameters: HTTPParemeters, headers: HTTPHeaders, media: [VZNetwork.Media]?) -> URLRequest? {
        var urlStr = url
        if method == "GET" {
            urlStr += URLHelper.getString(for: parameters)
        }
        
        guard let url = URL(string: urlStr) else { return nil }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = method
        request.add(headers: headers)
        
        if method == "POST" {
            request.httpBody = URLHelper.postData(for: parameters)
            if let media = media {
                URLHelper.configure(for: &request, with: media)
            }
        }
                
        return request
    }
}
