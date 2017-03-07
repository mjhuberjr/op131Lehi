import Vapor
import HTTP

final class UserController {
    
    func addRoutes(drop: Droplet) {
        let op131Lehi = drop.grouped("op131Lehi/users")
        op131Lehi.get("/", handler: fetchUsers)
        op131Lehi.get("/", LehiUser.self, handler: fetchMessagesByUser)
        
        op131Lehi.post("register", handler: register)
    }
    
    // MARK: - Get Routes
    
    func fetchUsers(request: Request) throws -> ResponseRepresentable {
        return try LehiUser.all().makeResponse()
    }
    
    func fetchMessagesByUser(request: Request, user: LehiUser) throws -> ResponseRepresentable {
        let messages = try user.messages()
        return try messages.makeResponse()
    }
    
    // MARK: - Post User
    
    func register(request: Request) throws -> ResponseRepresentable {
        
        guard let givenName = request.data[Keys.givenName]?.string,
            let surname = request.data[Keys.surname]?.string,
            let username = request.data[Keys.username]?.string,
            let password = request.data[Keys.password]?.string else {
                return "Missing information from the post"
        }
        
        _ = try LehiUser.register(givenName: givenName, surname: surname, username: username, rawPassword: password)
        return Response(redirect: "/")

    }
    
}

// MARK: - Messages

extension LehiUser {
    func messages() throws -> [Message] {
        return try children(nil, Message.self).all()
    }
}
