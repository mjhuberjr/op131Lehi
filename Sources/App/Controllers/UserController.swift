import Vapor
import HTTP

final class UserController {
    
    func addRoutes(drop: Droplet) {
        let op131Lehi = drop.grouped("op131Lehi/users")
        op131Lehi.get("/", handler: fetchUsers)
        op131Lehi.post("register", handler: register)
    }
    
    // MARK: - Get Routes
    
    func fetchUsers(request: Request) throws -> ResponseRepresentable {
        let usersNode = try LehiUser.all().makeNode()
        return try JSON(node: usersNode)
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
