import Vapor
import HTTP

final class MessageController {
    
    func addRoutes(drop: Droplet) {
        let op131Lehi = drop.grouped("op131Lehi/messages")
        op131Lehi.get("/", handler: fetchMessages)
        op131Lehi.get("/", Message.self, handler: fetchMessage)
    }
    
    // MARK: - Get Routes
    
    func fetchMessages(request: Request) throws -> ResponseRepresentable {
        return try Message.all().makeResponse()
    }
    
    func fetchMessage(request: Request, message: Message) throws -> ResponseRepresentable {
        return message
    }
    
    // MARK: - Post Routes
    
    func postMessage(request: Request) throws -> ResponseRepresentable {
        var message = try request.message()
        try message.save()
        return Response(redirect: "/")
    }
    
}
