import Vapor
import Turnstile
import TurnstileCrypto

final class LehiUser: Model {
    
    // MARK: - Conform to Entity
    
    var id: Node?
    var exists: Bool = false
    
    // MARK: - Properties
    
    var givenName: String
    var surname: String
    var username: Valid<UsernameValidator>
    var password: String
    var imagePath: String?
    
    init(givenName: String, surname: String, username: String, rawPassword: String, imagePath: String? = nil) {
        self.givenName = givenName
        self.surname = surname
        self.username = try username.validated()
        let validatedPassword: Valid<PasswordValidator> = try rawPassword.validated()
        self.password = BCrypt.hash(password: validatedPassword.value)
        self.imagePath = imagePath
    }
    
}
