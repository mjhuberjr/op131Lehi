import Vapor
import HTTP

final class Follow: Model {
    
    // MARK: - Conform to Entity
    
    var id: Node?
    var exists: Bool = false
    
    // MARK: - Properties
    
    var followerUserID: Int
    var followingUserID: Int
    
    // MARK: - Initializers
    
    init(followerUserID: Int, followingUserID: Int) throws {
        self.id = nil
        self.followerUserID = followerUserID
        self.followingUserID = followingUserID
    }
    
    // MARK: - NodeInitializable
    
    init(node: Node, in context: Context) throws {
        id = try node.extract(Keys.followID)
        followerUserID = try node.extract(Keys.followerUserID)
        followingUserID = try node.extract(Keys.followingUserID)
    }

    // MARK: - NodeRepresentable
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.followID: id,
            Keys.followerUserID: followerUserID,
            Keys.followingUserID: followingUserID
            ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Database) throws {
        try database.create(Keys.followDatabase) { follows in
            follows.id()
            follows.int(Keys.followerUserID)
            follows.int(Keys.followingUserID)
        }
    }
        
    static func revert(_ database: Database) throws {
        try database.delete(Keys.followDatabase)
    }
    
}

// MARK: - Response Representable

extension Follow: ResponseRepresentable {
    func makeResponse() throws -> Response {
        let json = try makeJSON()
        
        return try json.makeResponse()
    }
}

extension Sequence where Iterator.Element == Follow {
    func makeResponse() throws -> Response {
        let followArray = Array(self)
        let node = try followArray.makeNode()
        let json = try node.converted(to: JSON.self)
        
        return try json.makeResponse()
    }
}
