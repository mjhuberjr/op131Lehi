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
    
    var messageParentID: Node?
    var replies: [Message]?

    // MARK: - Initializers
    
    init(text: String, userID: Node? = nil, messageParentID: Node? = nil) throws {
        self.id = nil
        self.text = text
        self.userID = userID
        self.messageParentID = messageParentID
    }
    
    // MARK: - NodeInitializable
    
    init(node: Node, in context: Context) throws {
        id = try node.extract(Keys.messageID)
        
        userID = try node.extract(Keys.messageUserID)
        text = try node.extract(Keys.text)
        
        messageParentID = try node.extract(Keys.messageParentID)
    }
    
    // MARK: - NodeRepresentable
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.messageID: id,
            Keys.messageUserID: userID,
            Keys.text: text,
            Keys.messageParentID: messageParentID
            ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Database) throws {
        try database.create(Keys.messageDatabase) { messages in
            messages.id()
            messages.parent(LehiUser.self, optional: false)
            messages.string(Keys.text)
            messages.parent(Message.self, optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(Keys.messageDatabase)
    }
    
}

// MARK: - Relationship Methods

extension Message {
    func getAuthor() throws -> Parent<LehiUser> {
        return try parent(userID)
    }
    
    func getReplies() throws -> [Message] {
        return try children(nil, Message.self).all()
    }
}

// MARK: - Response Representable

extension Message: ResponseRepresentable {
    func makeResponse() throws -> Response {
        author = try getAuthor().get()
        replies = try getReplies()
        
        let json = try JSON(node: [
            Keys.messageID: id,
            Keys.messageUserID: userID,
            Keys.author: author,
            Keys.text: text,
            Keys.messageParentID: messageParentID,
            Keys.replies: replies?.makeNode()
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
