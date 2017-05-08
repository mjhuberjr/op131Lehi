import Vapor
import HTTP
import Turnstile
import TurnstileCrypto
import Auth

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
         access_token: String? = nil,
         imagePath: String? = nil) throws {
        
        self.givenName = try givenName.validated()
        self.surname = try surname.validated()
        self.username = try username.validated()
        let validatedPassword: Valid<PasswordValidator> = try rawPassword.validated()
        self.password = BCrypt.hash(password: validatedPassword.value)
        self.imagePath = imagePath ?? ""
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
    
    // MARK: - Preparation
    
    static func prepare(_ database: Database) throws {
        try database.create(Keys.lehiUserDatabase) { users in
            users.id()
            users.string(Keys.givenName)
            users.string(Keys.surname)
            users.string(Keys.username)
            users.string(Keys.password)
            users.string(Keys.imagePath)
            users.parent(Follow.self, optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(Keys.lehiUserDatabase)
    }
    
    // MARK: - Register User
    
    static func register(givenName: String,
                         surname: String,
                         username: String,
                         rawPassword: String,
                         imageName: String? = nil,
                         imageBytes: Bytes? = nil,
                         imagePath: String? = nil) throws -> LehiUser {

        var newUser = try LehiUser(givenName: givenName, surname: surname, username: username, rawPassword: rawPassword, imagePath: imagePath)
        if try LehiUser.query().filter(Keys.username, newUser.username.value).first() == nil {
            newUser.imagePath = try SaveImage.save(imageName: imageName, image: imageBytes)
            try newUser.save()

            return newUser
        } else {
            throw AccountTakenError()
        }
    }
    
}

// MARK: - Response Representable

extension LehiUser: ResponseRepresentable {
    func makeResponse() throws -> Response {
        let json = try makeJSON()
        
        return try json.makeResponse()
    }
}

extension Sequence where Iterator.Element == LehiUser {
    func makeResponse() throws -> Response {
        let usersArray = Array(self)
        let node = try usersArray.makeNode()
        let json = try node.converted(to: JSON.self)
        
        return try json.makeResponse()
    }
}

// MARK: - User Authentication

extension LehiUser: User {
    static func authenticate(credentials: Credentials) throws -> User {
        
        switch credentials {
        case let credentials as UsernamePassword:
            let fetchedUser = try LehiUser.query().filter(Keys.username, credentials.username).first()
            guard let user = fetchedUser else {
                throw UserDoesntExist()
            }

            if try BCrypt.verify(password: credentials.password, matchesHash: user.password) {
                return user
            } else {
                throw IncorrectCredentialsError()
            }
        case let credentials as Identifier:
            guard let user = try LehiUser.find(credentials.id) else {
                throw InvalidSessionError()
            }

            return user
        case let apiKey as APIKey:
            guard let user = try LehiUser.query().filter(Keys.username, apiKey.id).first() else {
                throw IncorrectCredentialsError()
            }

            if try BCrypt.verify(password: apiKey.secret, matchesHash: user.password) {
                return user
            } else {
                throw IncorrectCredentialsError()
            }
        default: throw UnsupportedCredentialsError()
        }
        
    }
    
    static func register(credentials: Credentials) throws -> User {
        throw Abort.badRequest
    }
}
