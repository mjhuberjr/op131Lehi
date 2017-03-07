import Vapor
import HTTP

final class UserController {
    
    func addRoutes(drop: Droplet) {
        let op131Lehi = drop.grouped("op131Lehi")
        op131Lehi.get("users", handler: fetchUsers)
    }
    
    // MARK: - User Routes
    
    func fetchUsers(request: Request) throws -> ResponseRepresentable {
        let usersNode = try LehiUser.all().makeNode()
        return try JSON(node: usersNode)
    }
    
}
