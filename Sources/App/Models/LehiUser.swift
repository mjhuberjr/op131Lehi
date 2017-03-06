import Vapor
import Turnstile
import TurnstileCrypto

final class LehiUser: Model {
    
    // MARK: - Conform to Entity
    
    var id: Node?
    var exists: Bool = false
    
    // MARK: - Properties
    
    var givenName: Valid<NameValidator>
    var surname: Valid<NameValidator>
    var username: Valid<UsernameValidator>
    var password: String
    var imagePath: String?
    
    // MARK: - Initializers
    
    init(givenName: String,
         surname: String,
         username: String,
         rawPassword: String,
         imagePath: String? = nil) throws {
        
        self.givenName = try givenName.validated()
        self.surname = try surname.validated()
        self.username = try username.validated()
        let validatedPassword: Valid<PasswordValidator> = try rawPassword.validated()
        self.password = BCrypt.hash(password: validatedPassword.value)
        self.imagePath = imagePath
    }
    
    // MARK: - NodeInitializable
    
    init(node: Node, in context: Context) throws {
        id = try node.extract(Keys.lehiUserID)
        
        let givenNameString = try node.extract(Keys.givenName) as String
        givenName = try givenNameString.validated()
        
        let surnameString = try node.extract(Keys.surname) as String
        surname = try surnameString.validated()
        
        let usernameString = try node.extract(Keys.username) as String
        username = try usernameString.validated()
        
        let passwordString = try node.extract(Keys.password) as String
        password = passwordString
        
        imagePath = try node.extract(Keys.imagePath) as String
    }
    
    // MARK: - NodeRepresentable
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.lehiUserID: id,
            Keys.givenName: givenName.value,
            Keys.surname: surname.value,
            Keys.username: username.value,
            Keys.password: password,
            Keys.imagePath: imagePath
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(Keys.lehiUserDatabase) { users in
            users.id()
            users.string(Keys.givenName)
            users.string(Keys.surname)
            users.string(Keys.username)
            users.string(Keys.password)
            users.string(Keys.imagePath)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(Keys.lehiUserDatabase)
    }
    
}
