/**
 A follow error is related to forming an incorrect relationship to another user.
 */
protocol FollowError: Error, CustomStringConvertible { }


/**
 FollowSelfError represents an error when the user tries to follow themself.
 */
struct FollowSelfError: FollowError {
    init() {}
    
    let description = "You cannot follow yourself."
}

/**
 AlreadyFollowingError represents an error when the user tries to follow a user they are already following them.
 */
struct AlreadyFollowingError: FollowError {
    init() {}
    
    let description = "You are already following this user."
}

/**
 UnFollowSelfError represents an error when the user tries to unfollow themself.
 */
struct UnFollowSelfError: FollowError {
    init() {}
    
    let description = "You cannot unfollow yourself."
}

/**
 NotFollowingError represents an error when the user tries to unfollow a user they are not following.
 */
struct NotFollowingError: FollowError {
    init() {}
    
    let description = "You are not following this user."
}
