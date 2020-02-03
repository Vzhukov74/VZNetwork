import Foundation

class URLHelper {
    class func boundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    class func createHttpDataBody(with parameters: HTTPHeaders?, media: [VZNetwork.Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        //start of body
        if let parameter = parameters {
            for (key, value) in parameter {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.type.rawValue + lineBreak + lineBreak)")
                body.append(photo.data)
            }
        }
        
        //end of body
        body.append("\(lineBreak)--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    class func configure(for request: inout URLRequest, with media: [VZNetwork.Media]) {
        media.forEach { $0.setupHeaderFields(request: &request) }
        
        if media.count == 1 {
            if let media = media.first, media.type == .json {
                request.httpBody = media.data
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                return
            }
        }
        
        let boundary = URLHelper.boundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = URLHelper.createHttpDataBody(with: nil, media: media, boundary: boundary)
    }
    
    class func postData(for params: HTTPParemeters?) -> Data? {
        guard let params = params else { return nil }
        var data = [String]()
        for(key, value) in params {
            if value is [String: Any] {
                assert(true, "need to implement for dictionary!")
            } else if value is [Any] {
                for _value in value as! [Any] {
                    if let _valueStr = _value as? String {
                        data.append(key + "[]=\(_valueStr.addingPercentEncodingForQueryParameter() ?? _valueStr)")
                    } else {
                        data.append(key + "[]=\(_value)")
                    }
                }
            } else {
                if let valueStr = value as? String {
                     data.append(key + "=\(valueStr.addingPercentEncodingForQueryParameter() ?? valueStr)")
                } else {
                     data.append(key + "=\(value)")
                }
            }
        }
        let str = data.map { String($0) }.joined(separator: "&")

        return str.data(using: .utf8, allowLossyConversion: true)
    }
    
    class func getString(for params: HTTPParemeters?) -> String {
        guard let params = params else { return "" }
        let separator = "&"
        var str = ""
        for(key, value) in params {
            if value is [String: Any] {
                assert(true, "need to implement for dictionary!")
            } else if value is [Any] {
                for _value in value as! [Any] {
                    str += key + "[]=\(_value)" + separator
                }
            } else {
                str += key + "=\(value)" + separator
            }
        }
        _ = str.removeLast()
        
        return "?" + str
    }
}
