import Vapor

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
    
}
