import Vapor
import VaporMySQL

// MARK: - Setup Vapor and Database Preparations

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider)
drop.preparations += LehiUser.self

// MARK: - Setup Routes

let userController = UserController()
userController.addRoutes(drop: drop)

drop.run()
