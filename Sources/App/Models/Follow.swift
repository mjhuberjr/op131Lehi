import Vapor
import HTTP

final class Follow: Model {
    
    // MARK: - Conform to Entity
    
    var id: Node?
    var exists: Bool = false
    
    // MARK: - Properties
    
    var followUserID: Int
    var followingUserID: Int
    
    // MARK: - Initializers
    
    init(followUserID: Int, followingUserID: Int) throws {
        self.id = nil
        self.followUserID = followUserID
        self.followingUserID = followingUserID
    }
    
    // MARK: - NodeInitializable
    
    init(node: Node, in context: Context) throws {
        id = try node.extract(Keys.followID)
        followUserID = try node.extract(Keys.followUserID)
        followingUserID = try node.extract(Keys.followingUserID)
    }

    // MARK: - NodeRepresentable
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.followID: id,
            Keys.followUserID: followUserID,
            Keys.followingUserID: followingUserID
            ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Database) throws {
        try database.create(Keys.followDatabase) { follows in
            follows.id()
            follows.int(Keys.followUserID)
            follows.int(Keys.followingUserID)
        }
    }
        
    static func revert(_ database: Database) throws {
        try database.delete(Keys.followDatabase)
    }
    
}
