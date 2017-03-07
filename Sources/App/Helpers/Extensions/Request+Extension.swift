import Vapor
import HTTP

extension Request {
    func user() throws -> LehiUser {
        guard let json = json else { throw Abort.badRequest }
        return try LehiUser(node: json)
    }
    
    func message() throws -> Message {
        guard let json = json else { throw Abort.badRequest }
        return try Message(node: json)
    }
}
