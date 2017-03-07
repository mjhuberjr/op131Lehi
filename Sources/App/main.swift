import Vapor
import VaporMySQL

// MARK: - Setup Vapor and Database Preparations

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider)
drop.preparations += LehiUser.self
drop.preparations += Message.self

// MARK: - Setup Routes

let userController = UserController()
userController.addRoutes(drop: drop)

let messageController = MessageController()
messageController.addRoutes(drop: drop)

drop.run()
