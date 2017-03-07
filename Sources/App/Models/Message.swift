import Vapor
import HTTP
import Fluent

final class Message: Model {
    
    // MARK: - Conform to Entity
    
    var id: Node?
    var exists: Bool = false
    
    // MARK: - Properties
    
    var userID: Node?
    var author: LehiUser? = nil
    var text: String

    // MARK: - Initializers
    
    init(text: String, userID: Node? = nil) throws {
        self.id = nil
        self.text = text
        self.userID = userID
    }
    
    // MARK: - NodeInitializable
    
    init(node: Node, in context: Context) throws {
        id = try node.extract(Keys.messageID)
        
        userID = try node.extract(Keys.messageUserID)
        text = try node.extract(Keys.text)
        
        author = try getAuthor().get()
    }
    
    // MARK: - NodeRepresentable
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.messageID: id,
            Keys.messageUserID: userID,
            Keys.author: author,
            Keys.text: text
            ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Database) throws {
        try database.create(Keys.messageDatabase) { messages in
            messages.id()
            messages.parent(LehiUser.self, optional: false)
            messages.string(Keys.text)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(Keys.messageDatabase)
    }
    
}

// MARK: - Return Author

extension Message {
    func getAuthor() throws -> Parent<LehiUser> {
        return try parent(userID)
    }
}

// MARK: - Response Representable

extension Message: ResponseRepresentable {
    func makeResponse() throws -> Response {
        let json = try JSON(node: [
            Keys.messageID: id,
            Keys.messageUserID: userID,
            Keys.author: author,
            Keys.text: text
            ])
        
        return try json.makeResponse()
    }
}

extension Sequence where Iterator.Element == Message {
    func makeResponse() throws -> Response {
        let messagesArray = Array(self)
        let nodeArray = try messagesArray.makeNode()
        let json = try nodeArray.converted(to: JSON.self)
        
        return try json.makeResponse()
    }
}
