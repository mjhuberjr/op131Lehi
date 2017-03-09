import Vapor
import HTTP

final class FollowController {
    
    func addRoutes(drop: Droplet) {
        let op131Lehi = drop.grouped("op131Lehi/users")
        op131Lehi.get(":followUserID", "follows", handler: fetchFollowing)
        op131Lehi.get(":followUserID", "followers", handler: fetchFollowers)
        
        op131Lehi.post(":followUserID", "follows", ":followingUserID", handler: followUser)
    }
    
    // MARK: - Get Routes
    
    func fetchFollowing(request: Request) throws -> ResponseRepresentable {
        let followUserID = try request.parameters.extract(Keys.followUserID) as Int
        let follows = try Follow.query().filter(Keys.followUserID, followUserID).all()
        
        let users = try follows.flatMap { try LehiUser.find($0.followingUserID) }
        
        return try users.makeResponse()
    }
    
    func fetchFollowers(request: Request) throws -> ResponseRepresentable {
        let followUserID = try request.parameters.extract(Keys.followUserID) as Int
        let followers = try Follow.query().filter(Keys.followingUserID, followUserID).all()
        
        let users = try followers.flatMap { try LehiUser.find($0.followUserID) }
        
        return try users.makeResponse()
    }
    
    // MARK: - Post Routes
    
    func followUser(request: Request) throws -> ResponseRepresentable {
        let followUserID = try request.parameters.extract("followUserID") as Int
        let followingUserID = try request.parameters.extract("followingUserID") as Int
        
        if followUserID == followingUserID {
            throw FollowSelfError()
        }
        
        
        let followers = try Follow.query().filter(Keys.followUserID, followUserID).all()
        var follow = try Follow(followUserID: followUserID, followingUserID: followingUserID)
        
        let isFollowing = followers.filter { $0.followingUserID == follow.followingUserID }
        
        if isFollowing.isEmpty {
            try follow.save()
            return Response(redirect: "/")
        } else {
            throw AlreadyFollowingError()
        }
    }
    
}
