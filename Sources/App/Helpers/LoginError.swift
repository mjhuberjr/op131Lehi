/** 
 A login error occurs when a user enters incorrect login information.
 */

protocol LoginError: Error, CustomStringConvertible { }

/**
 BlankUsername represents an error when the user fails to provide a username.
 */

struct BlankUsername: LoginError {
    init() {}
    
    let description = "You need to enter a username."
}

/**
 BlankPassword represents an error when the user fails to provide a password.
 */

struct BlankPassword: LoginError {
    init() {}
    
    let description = "You need to enter a password."
}

/**
 UserDoesntExist represents an error when the user they are trying to sign in as does not exist.
 */

struct UserDoesntExist: LoginError {
    init() {}
    
    let description = "User doesn't exist."
}
