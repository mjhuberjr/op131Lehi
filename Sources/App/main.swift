import Vapor
import VaporMySQL

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider)

// Preparations of your model here

drop.get("version") { _ in
    if let db = drop.database?.driver as? MySQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    } else {
        return "Database Connection failed..."
    }
}

drop.run()
