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
        id = try node.extract(Keys.LehiUserID)
        
        let givenNameString = try node.extract(Keys.givenName) as String
        givenName = try givenNameString.validated()
        
        let surnameString = try node.extract(Keys.surname) as String
        surname = try surnameString.validated()
        
        let passwordString = try node.extract(Keys.password) as String
        password = passwordString
        
        imagePath = try node.extract(Keys.imagePath) as String
    }
    
    // MARK: - NodeRepresentable
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.LehiUserID: id,
            Keys.givenName: givenName.value,
            Keys.surname: surname.value,
            Keys.password: password,
            Keys.imagePath: imagePath
            ])
    }
    
}
