import Vapor
import HTTP
import Auth
import Turnstile

final class UserController {
    
    func addRoutes(drop: Droplet) {
        let op131Lehi = drop.grouped("op131Lehi/users")
        op131Lehi.post("register", handler: register)
        op131Lehi.post("login", handler: login)
        
        // MARK: - Protected Routes
        // TODO: Again need it's own middleware to handle authentication correctly

        let op131LehiProtected = drop.grouped("op131Lehi/users")
        op131LehiProtected.get("/", handler: queryMessagesByUser)
        op131LehiProtected.get("/", LehiUser.self, handler: fetchMessagesByUser)
        op131LehiProtected.get("logout", handler: logout)
        
        op131LehiProtected.post("/", LehiUser.self, handler: updateProfile)
    }
    
    // MARK: - Get Routes

    func queryMessagesByUser(request: Request) throws -> ResponseRepresentable {
        guard let credentials = request.auth.header?.basic else { throw InvalidSessionError() }
        try request.auth.login(credentials)

        guard let username = request.query?[Keys.username]?.string else { throw Abort.badRequest }
        guard let user = try LehiUser.query().filter(Keys.username, contains: username).first() else { throw UserDoesntExist() }

        let messages = try user.messages()
        return try messages.makeResponse()
    }
    
    func fetchMessagesByUser(request: Request, user: LehiUser) throws -> ResponseRepresentable {
        guard let credentials = request.auth.header?.basic else { throw InvalidSessionError() }
        try request.auth.login(credentials)

        let messages = try user.messages()
        return try messages.makeResponse()
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        guard let credentials = request.auth.header?.basic else { throw InvalidSessionError() }
        try request.auth.login(credentials)
        try request.auth.logout()
        return Response(redirect: "/")
    }
    
    // MARK: - Post User
    
    // TODO: Refactor, a lot of similar code
    
    func register(request: Request) throws -> ResponseRepresentable {
        if request.headers["Content-Type"] == "application/json" {
            if let user = try request.user() {
                _ = try LehiUser.register(givenName: user.givenName.value,
                                          surname: user.surname.value,
                                          username: user.username.value,
                                          rawPassword: user.password)
                
                let credentials = UsernamePassword(username: user.username.value, password: user.password)
                try request.auth.login(credentials)
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
                
                let credentials = UsernamePassword(username: userWithImage.username.value, password: userWithImage.password)
                try request.auth.login(credentials)
            }
        }
        
        return Response(redirect: "/")

    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        guard let credentials = request.auth.header?.basic else { throw Abort.badRequest }

        do {
            try request.auth.login(credentials)

            return Response(redirect: "/")
        } catch let error as TurnstileError {
            return error.description
        }
        
    }
    
    func updateProfile(request: Request, profile: LehiUser) throws -> ResponseRepresentable {
        guard let credentials = request.auth.header?.basic else { throw InvalidSessionError() }
        try request.auth.login(credentials)
        
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
