import Vapor
import HTTP

final class Message: Model {
    
    // MARK: - Conform to Entity
    
    var id: Node?
    var exists: Bool = false
    
    // MARK: - Properties
    
    var userID: Node?
    var text: String

    // MARK: - Initializers
    
    init(text: String, userID: Node? = nil) {
        self.id = nil
        self.text = text
        self.userID = userID
    }
    
    // MARK: - NodeInitializable
    
    init(node: Node, in context: Context) throws {
        id = try node.extract(Keys.messageID)
        
        userID = try node.extract(Keys.messageUserID)
        text = try node.extract(Keys.text)
    }
    
    // MARK: - NodeRepresentable
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.messageID: id,
            Keys.messageUserID: userID,
            Keys.text: text
            ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Database) throws {
        try database.create(Keys.messageDatabase) { messages in
            messages.id()
            messages.parent(LehiUser.self, optional: false)
            messages.string("messages")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(Keys.messageDatabase)
    }
    
}

// MARK: - Response Representable

extension Message: ResponseRepresentable {
    func makeResponse() throws -> Response {
        let response = Response()
        response.message = self
        
        return response
    }
}
