import Vapor
import HTTP

extension Request {
    func user() throws -> LehiUser {
        guard let json = json else { throw Abort.badRequest }
        return try LehiUser(node: json)
    }
    
    func userWithImage() throws -> LehiUser {
        guard let userData = formData,
            let givenName = userData[Keys.givenName]?.string,
            let surname = userData[Keys.surname]?.string,
            let username = userData[Keys.username]?.string,
            let password = userData[Keys.password]?.string else { throw Abort.badRequest }
        
        let imagePath = ""
        
        return try LehiUser(givenName: givenName, surname: surname, username: username, rawPassword: password, imagePath: imagePath)
    }
    
    func message() throws -> Message {
        guard let json = json else { throw Abort.badRequest }
        return try Message(node: json)
    }
}
