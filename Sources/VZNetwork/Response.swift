import Foundation

public extension VZNetwork {
    class Response {
        public let response: HTTPURLResponse
        public let data: Data
        
        var code: Int { return response.statusCode }
        var isSuccess: Bool { return code == 200 }
        var etag: String? { return response.allHeaderFields["Etag"] as? String }
        var description: String? { return try? JSONSerialization.jsonObject(with: data, options: []) as? String }
        
        public init?(response: HTTPURLResponse?, data: Data?) {
            guard let response = response, let data = data else { return nil }
            self.response = response
            self.data = data
        }
        
        public func decode<T: Codable>() -> T? {
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
    }
}
