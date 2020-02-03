import Foundation
#if canImport(UIKit)
import UIKit
#endif

public class VZNetwork {}

extension URLSession {
    func dataTask(with request: VZNetwork.Request) -> URLSessionDataTask {
        return self.dataTask(with: request.request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                request._end?()
                #if canImport(UIKit)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                #endif
            }
                                            
            if let error = error {
                DispatchQueue.main.async {
                    request._result?(.fail(error.localizedDescription))
                }
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            if let response = VZNetwork.Response(response: httpResponse, data: data) {
                DispatchQueue.main.async {
                    request._result?(.success(response))
                }
            } else {
                DispatchQueue.main.async {
                    request._result?(.fail(""))
                }
            }
        })
    }
    
    func perform(with request: VZNetwork.Request) {
        self.dataTask(with: request).resume()
        DispatchQueue.main.async {
            request._start?()
            #if canImport(UIKit)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            #endif
        }
    }
}
