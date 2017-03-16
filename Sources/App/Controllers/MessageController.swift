import Vapor
import HTTP
import Auth
import Turnstile

// TODO: Need to move the credentials and login into it's own ProtectMiddleware. Don't want to have to put that in each route. Also want to be able to seperate private routes and public routes for the future.

final class MessageController {
    
    func addRoutes(drop: Droplet) {
        
        let op131Lehi = drop.grouped("op131Lehi/messages")
        op131Lehi.get("/", handler: fetchMessages)
        op131Lehi.get("/", Message.self, handler: fetchMessage)
        
        op131Lehi.post("/", handler: postMessage)
        op131Lehi.post("/", Message.self, handler: updateMessage)
        
        op131Lehi.delete("/", Message.self, handler: deleteMessage)
    }
    
    // MARK: - Get Routes
    
    func fetchMessages(request: Request) throws -> ResponseRepresentable {

        guard let credentials = request.auth.header?.basic else { throw InvalidSessionError() }
        try request.auth.login(credentials)

        if let query = request.query?["id"]?.int {
            guard let message = try Message.find(query) else { throw Abort.badRequest }
            return message
        }

        return try Message.all().makeResponse()
    }
    
    func fetchMessage(request: Request, message: Message) throws -> ResponseRepresentable {
        guard let credentials = request.auth.header?.basic else { throw InvalidSessionError() }
        try request.auth.login(credentials)

        return message
    }
    
    // MARK: - Post Routes
    
    func postMessage(request: Request) throws -> ResponseRepresentable {
        guard let credentials = request.auth.header?.basic else { throw InvalidSessionError() }
        try request.auth.login(credentials)

        var message = try request.message()
        try message.save()
        return Response(redirect: "/")
    }
    
    func updateMessage(request: Request, message: Message) throws -> ResponseRepresentable {
        guard let credentials = request.auth.header?.basic else { throw InvalidSessionError() }
        try request.auth.login(credentials)
        
        let newMessage = try request.message()
        
        var message = message
        message.text = newMessage.text
        
        try message.save()
        
        return Response(redirect: "/")
        
    }
    
    // MARK: - Delete Routes
    
    func deleteMessage(request: Request, message: Message) throws -> ResponseRepresentable {
        guard let credentials = request.auth.header?.basic else { throw InvalidSessionError() }
        try request.auth.login(credentials)

        try message.delete()
        return Response(redirect: "/")
    }
    
}
