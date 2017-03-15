import Foundation

enum Keys {
    
    // MARK: - LehiUser Keys
    
    static let lehiUserDatabase = "lehiusers"
    static let lehiUserID = "id"
    static let givenName = "givenName"
    static let surname = "surname"
    static let username = "username"
    static let password = "password"
    static let imagePath = "imagePath"
    static let image = "image"
    static let accesstoken = "access_token"
    
    // MARK: - Message Keys
    
    static let messageDatabase = "messages"
    static let messageID = "id"
    static let text = "text"
    static let createdAt = "createdAt"
    static let messageUserID = "lehiuser_id"
    static let author = "author"
    static let messageParentID = "message_id"
    static let replies = "replies"
    
    // MARK: - Follow Keys
    
    static let followDatabase = "follows"
    static let followID = "id"
    static let followUserID = "followUserID"
    static let followingUserID = "followingUserID"
    
}

