import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8, allowLossyConversion: true) {
            append(data)
        }
    }
}

extension String {
    public func addingPercentEncodingForQueryParameter() -> String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        return allowed
    }()
}

extension URLRequest {
    mutating func add(headers: HTTPHeaders?) {
        guard let headers = headers else { return }
        
        for (key, value) in headers {
            self.addValue(value, forHTTPHeaderField: key)
        }
    }
}
