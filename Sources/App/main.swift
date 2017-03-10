import Vapor
import VaporMySQL
import Auth

// MARK: - Setup Vapor and Database Preparations

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider)
drop.preparations += LehiUser.self
drop.preparations += Message.self
drop.preparations += Follow.self

// MARK: - Middleware

let auth = AuthMiddleware(user: LehiUser.self)
drop.middleware.append(auth)

// MARK: - Setup Routes

let userController = UserController()
userController.addRoutes(drop: drop)

let messageController = MessageController()
messageController.addRoutes(drop: drop)

let followController = FollowController()
followController.addRoutes(drop: drop)

drop.run()
