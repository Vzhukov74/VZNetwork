import Foundation
#if canImport(UIKit)
import UIKit
#endif

extension VZNetwork {
    public struct Media {
        public enum `Type`: String {
            case image = "image/png"
            case json = "json"
        }
        
        public let key: String
        public let filename: String
        public let data: Data
        public let type: Type
        public var mimeType: String { return type.rawValue }
        
        public init(with data: Data, for key: String, type: Type, filename: String) {
            self.key = key
            self.type = type
            self.filename = filename
            self.data = data
        }
        
        #if canImport(UIKit)
        public init?(with image: UIImage, for key: String, filename: String = "file.png") {
            guard let data = image.jpegData(compressionQuality: 0.2) else { return nil }
            
            self.key = key
            self.type = .image
            self.filename = filename
            self.data = data
        }
        #endif
        
        public init(with json: Data, for key: String, filename: String = "") {
            self.key = key
            self.type = .json
            self.filename = filename
            self.data = json
        }
        
        public init?(with json: HTTPParemeters, for key: String, filename: String = "") {
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return nil }
            
            self.key = key
            self.type = .json
            self.filename = filename
            self.data = data
        }
        
        func setupHeaderFields(request: inout URLRequest) {
            switch type {
            case .image:
                let boundary = URLHelper.boundary()
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            case .json:
                request.httpBody = data
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
            }
        }
    }
}
