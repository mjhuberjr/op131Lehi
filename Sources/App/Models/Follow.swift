import Vapor
import HTTP

final class Follow: Model {
    
    // MARK: - Conform to Entity
    
    var id: Node?
    var exists: Bool = false
    
    // MARK: - Properties
    
    var followingUserID: Int
    
    // MARK: - Initializers
    
    init(followingUserID: Int) throws {
        self.id = nil
        self.followingUserID = followingUserID
    }
    
    // MARK: - NodeInitializable
    
    init(node: Node, in context: Context) throws {
        id = try node.extract(Keys.followID)
        followingUserID = try node.extract(Keys.followUserID)
    }

    // MARK: - NodeRepresentable
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.followID: id,
            Keys.followUserID: followingUserID
            ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Database) throws {
        try database.create(Keys.followDatabase) { follows in
            follows.id()
            follows.int(Keys.followUserID)
        }
    }
        
    static func revert(_ database: Database) throws {
        try database.delete(Keys.followDatabase)
    }
    
}
