import Vapor
import HTTP

final class FollowController {
    
    func addRoutes(drop: Droplet) {
        let op131Lehi = drop.grouped("op131Lehi/users")
        op131Lehi.get(LehiUser.self, "follows", handler: fetchFollowing)
        op131Lehi.get(LehiUser.self, "followers", handler: fetchFollowers)
        
        op131Lehi.post(LehiUser.self, "follows", LehiUser.self, handler: followUser)
    }
    
    // MARK: - Get Routes
    
    func fetchFollowing(request: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func fetchFollowers(request: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    // MARK: - Post Routes
    
    func followUser(request: Request, user: LehiUser) throws -> ResponseRepresentable {
        return ""
    }
    
}
