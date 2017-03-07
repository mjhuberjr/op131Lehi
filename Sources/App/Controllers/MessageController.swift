import Vapor
import HTTP

final class MessageController {
    
    func addRoutes(drop: Droplet) {
        let op131Lehi = drop.grouped("op131Lehi/messages")
        op131Lehi.get("/", handler: fetchMessages)
    }
    
    // MARK: - Get Routes
    
    func fetchMessages(request: Request) throws -> ResponseRepresentable {
        let messagesNode = try Message.all().makeNode()
        return try JSON(node: messagesNode)
    }
    
    // MARK: - Post Routes
    
}
