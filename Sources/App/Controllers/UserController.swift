import Vapor
import HTTP

final class UserController {
    
    func addRoutes(drop: Droplet) {
        let op131Lehi = drop.grouped("op131Lehi/users")
        op131Lehi.get("/", handler: fetchUsers)
        op131Lehi.get("/", LehiUser.self, handler: fetchMessagesByUser)
        
        op131Lehi.post("register", handler: register)
        op131Lehi.post("/", LehiUser.self, handler: updateProfile)
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
        
        throw Abort.badRequest

    }
    
    func updateProfile(request: Request, profile: LehiUser) throws -> ResponseRepresentable {
        
        if request.headers["Content-Type"] == "application/json" {
            
            guard let user = try request.user() else { throw Abort.badRequest }
            
            var profile = profile
            profile.givenName = try user.givenName.value.validated()
            profile.surname =  try user.surname.value.validated()
            
            // TODO: Eventually add ability to change password.
            
            try profile.save()
            
            return Response(redirect: "/")
            
        } else if let _ = request.headers["Content-Type"]?.contains("multipart/form-data") {
            
            guard let userWithImage = try request.userWithImage(),
                let imageName = request.formData?[Keys.image]?.filename,
                let imageBytes = request.formData?[Keys.image]?.part.body else {
                    throw Abort.badRequest
            }
            
            var profile = profile
            
            profile.givenName = try userWithImage.givenName.value.validated()
            profile.surname = try userWithImage.surname.value.validated()
            try SaveImage.removeImage(for: profile.imagePath)
            profile.imagePath = try SaveImage.save(imageName: imageName, image: imageBytes)
            
            try profile.save()
            
            return Response(redirect: "/")
            
        }
        
        throw Abort.badRequest
        
    }
    
}

// MARK: - Messages

extension LehiUser {
    func messages() throws -> [Message] {
        let messages = try children(nil, Message.self).all()
        return messages.filter { $0.messageParentID == nil }
    }
}
