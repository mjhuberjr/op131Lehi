import Vapor
import VaporMySQL

let drop = droplet()
try drop.addProvider(VaporMySQL.Provider)

// Preparations of your model here

drop.run()
