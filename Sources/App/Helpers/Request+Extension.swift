import Vapor
import HTTP

extension Request {
    func message() throws -> Message {
        guard let json = json else { throw Abort.badRequest }
        return try Message(node: json)
    }
}
