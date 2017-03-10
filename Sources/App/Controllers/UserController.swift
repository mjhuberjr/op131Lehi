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
        if request.headers["Content-Type"] == "application/json" {
            if let user = try request.user() {
                _ = try LehiUser.register(givenName: user.givenName.value,
                                          surname: user.surname.value,
                                          username: user.username.value,
                                          rawPassword: user.password)
            }
        } else if let _ = request.headers["Content-Type"]?.contains("multipart/form-data") {
            if let userWithImage = try request.userWithImage() {
                guard let imageName = request.formData?[Keys.image]?.filename,
                    let imageBytes = request.formData?[Keys.image]?.part.body else {
                        throw Abort.badRequest
                }
                
                    _ = try LehiUser.register(givenName: userWithImage.givenName.value,
                                              surname: userWithImage.surname.value,
                                              username: userWithImage.username.value,
                                              rawPassword: userWithImage.password,
                                              imageName: imageName,
                                              imageBytes: imageBytes)
            }
        }
        
        return Response(redirect: "/")

    }
    
}

// MARK: - Messages

extension LehiUser {
    func messages() throws -> [Message] {
        let messages = try children(nil, Message.self).all()
        return messages.filter { $0.messageParentID == nil }
    }
}
