import Foundation

public extension VZNetwork {
    enum Result {
        case success(Response)
        case fail(String)
    }
}
