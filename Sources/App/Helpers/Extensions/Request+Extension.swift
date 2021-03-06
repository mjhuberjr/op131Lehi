import Vapor
import HTTP

extension Request {
    func user() throws -> LehiUser? {
        guard let json = json else { throw Abort.badRequest }
        return try LehiUser(node: json)
    }
    
    func userWithImage() throws -> LehiUser? {
        guard let userData = formData else { throw Abort.badRequest }
        guard let givenName = userData[Keys.givenName]?.string,
            let surname = userData[Keys.surname]?.string,
            let username = userData[Keys.username]?.string,
            let password = userData[Keys.password]?.string,
            let imagePath = userData[Keys.imagePath]?.string else { throw Abort.badRequest }
        
        let json = try JSON(node: [
            Keys.givenName: givenName,
            Keys.surname: surname,
            Keys.username: username,
            Keys.password: password,
            Keys.imagePath: imagePath
            ])
        
        return try LehiUser(node: json)
    }
    
    func message() throws -> Message {
        guard let json = json else {
            guard let userID = data[Keys.messageUserID]?.string,
                let text = data[Keys.text]?.string else { throw Abort.badRequest }

            let messageParentID = data[Keys.messageParentID]?.int

            let json = try JSON(node: [
                Keys.messageUserID: userID,
                Keys.text: text,
                Keys.messageParentID: messageParentID
                ])

            return try Message(node: json)
        }

        return try Message(node: json)
    }
}
