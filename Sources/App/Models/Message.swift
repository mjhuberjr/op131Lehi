import Vapor
import HTTP
import Fluent

import Foundation

final class Message: Model {
    
    // MARK: - Conform to Entity
    
    var id: Node?
    var exists: Bool = false
    
    // MARK: - Properties
    
    var userID: Node?
    var author: LehiUser? = nil
    var text: String
    var createdAt: String?
    
    var messageParentID: Node?
    var replies: [Message]?

    // MARK: - Initializers
    
    init(text: String, userID: Node? = nil, messageParentID: Node? = nil) throws {
        self.id = nil
        self.text = text
        self.userID = userID
        self.messageParentID = messageParentID
        self.createdAt = Date().current()
    }
    
    // MARK: - NodeInitializable
    
    init(node: Node, in context: Context) throws {
        id = try node.extract(Keys.messageID)
        
        userID = try node.extract(Keys.messageUserID)
        text = try node.extract(Keys.text)
        createdAt = Date().current()
        
        messageParentID = try node.extract(Keys.messageParentID)
    }
    
    // MARK: - NodeRepresentable
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.messageID: id,
            Keys.messageUserID: userID,
            Keys.text: text,
            Keys.createdAt: createdAt,
            Keys.messageParentID: messageParentID
            ])
    }
    
    // MARK: - JSONRepresentable
    
    func makeJSON() throws -> JSON {
        author = try getAuthor().get()
        replies = try getReplies()
        
        return try JSON(node: [
            Keys.messageID: id,
            Keys.messageUserID: userID,
            Keys.author: author,
            Keys.text: text,
            Keys.createdAt: createdAt,
            Keys.messageParentID: messageParentID,
            Keys.replies: replies?.makeJSON()
            ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Database) throws {
        try database.create(Keys.messageDatabase) { messages in
            messages.id()
            messages.parent(LehiUser.self, optional: false)
            messages.string(Keys.text)
            messages.string(Keys.createdAt)
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
        let json = try makeJSON()
        
        return try json.makeResponse()
    }
}

extension Sequence where Iterator.Element == Message {
    func makeResponse() throws -> Response {
        let messagesArray = Array(self)
        
        let jsonArray = try messagesArray.map { (message) -> JSON in
            let json = try message.makeJSON()
            
            return json
        }
        
        let node = try jsonArray.makeNode()
        let json = try node.converted(to: JSON.self)
        
        return try json.makeResponse()
    }
}
